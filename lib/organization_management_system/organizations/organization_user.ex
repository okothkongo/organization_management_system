defmodule OrganizationManagementSystem.Organizations.OrganizationUser do
  @moduledoc """
  The OrganizationUser schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "organisation_users" do
    belongs_to :organisation, OrganizationManagementSystem.Organizations.Organization
    belongs_to :user, OrganizationManagementSystem.Accounts.User
    belongs_to :invited_by, OrganizationManagementSystem.Accounts.User
    belongs_to :role, OrganizationManagementSystem.Accounts.Role

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization_user, attrs, user_scope) do
    organization_user
    |> cast(attrs, [:organisation_id, :user_id, :role_id])
    |> validate_required([:organisation_id, :user_id])
    |> put_change(:invited_by_id, user_scope.user.id)
    |> unique_constraint([:organisation_id, :user_id],
      name: :organisation_users_organisation_id_user_id_index,
      message: "This user is already a member of the organization"
    )
  end
end
