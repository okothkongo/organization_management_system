defmodule OrganizationManagementSystem.Accounts.UserRole do
  @moduledoc """
  Schema representing the association between users and roles, defining the scope of the role
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias OrganizationManagementSystem.Accounts.{User, Role}
  alias OrganizationManagementSystem.Organizations.Organization

  schema "user_roles" do
    belongs_to :user, User
    belongs_to :role, Role
    field :scope, Ecto.Enum, values: [:global, :organisation]
    belongs_to :organisation, Organization

    timestamps(type: :utc_datetime)
  end

  def changeset(user_role, attrs) do
    user_role
    |> cast(attrs, [:user_id, :role_id, :scope, :organisation_id])
    |> validate_required([:user_id, :role_id, :scope])
    |> validate_org_scope()
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:role_id)
    |> foreign_key_constraint(:organisation_id)
    |> unique_constraint([:user_id, :role_id, :organisation_id],
      name: :user_roles_with_org_unique_index,
      message: "User already has this role in this organisation"
    )
    |> unique_constraint([:user_id, :role_id],
      name: :user_roles_without_org_unique_index,
      message: "User already has this global role"
    )
  end

  defp validate_org_scope(changeset) do
    scope = get_field(changeset, :scope)
    org_id = get_field(changeset, :organisation_id)

    if scope == :organisation and is_nil(org_id) do
      add_error(changeset, :organisation_id, "must be present for organization-scoped roles")
    else
      changeset
    end
  end
end
