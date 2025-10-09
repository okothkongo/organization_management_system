defmodule OrganizationManagementSystem.Organizations.OrganizationUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "organization_users" do
    belongs_to :organization, OrganizationManagementSystem.Organizations.Organization
    belongs_to :user, OrganizationManagementSystem.Accounts.User
    belongs_to :invited_by, OrganizationManagementSystem.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization_user, attrs, user_scope) do
    organization_user
    |> cast(attrs, [])
    |> validate_required([])
    |> put_change(:invited_by_id, user_scope.user.id)
  end
end
