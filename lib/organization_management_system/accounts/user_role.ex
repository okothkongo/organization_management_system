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

  @spec changeset(
          {map(),
           %{
             optional(atom()) =>
               atom()
               | {:array | :assoc | :embed | :in | :map | :parameterized | :supertype | :try,
                  any()}
           }}
          | %{
              :__struct__ => atom() | %{:__changeset__ => any(), optional(any()) => any()},
              optional(atom()) => any()
            },
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: Ecto.Changeset.t()
  def changeset(user_role, attrs) do
    user_role
    |> cast(attrs, [:user_id, :role_id, :scope, :organisation_id])
    |> validate_required([:user_id, :role_id, :scope])
    |> validate_org_scope()
    |> unique_constraint([:user_id, :role_id, :organisation_id])
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
