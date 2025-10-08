defmodule OrganizationManagementSystem.Accounts.RolePermission do
  @moduledoc """
  RolePermission Schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "role_permissions" do
    belongs_to :role, OrganizationManagementSystem.Accounts.Role
    belongs_to :permission, OrganizationManagementSystem.Accounts.Permission

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(role_permission, attrs) do
    role_permission
    |> cast(attrs, [:role_id, :permission_id])
    |> validate_required([:role_id, :permission_id])
  end
end
