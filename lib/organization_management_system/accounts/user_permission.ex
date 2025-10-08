defmodule OrganizationManagementSystem.Accounts.UserPermission do
  @moduledoc """
  UserPermission Schema
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias OrganizationManagementSystem.Accounts.Permission
  alias OrganizationManagementSystem.Accounts.User

  schema "user_permissions" do
    belongs_to :user, User
    belongs_to :permission, Permission
    belongs_to :granted_by, User, foreign_key: :granted_by_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_permission, attrs, scope) do
    user_permission
    |> cast(attrs, [:user_id, :permission_id])
    |> validate_required([:user_id, :permission_id])
    |> put_change(:granted_by_id, scope.user.id)
  end
end
