defmodule OrganizationManagementSystem.Accounts.Permission do
  @moduledoc """
  Permission Schema
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias OrganizationManagementSystem.Accounts.Role
  alias OrganizationManagementSystem.Accounts.RolePermission

  schema "permissions" do
    field :action, :string
    field :description, :string

    many_to_many :roles, Role, join_through: RolePermission
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:action, :description])
    |> validate_required([:action, :description])
    |> unique_constraint(:action)
  end
end
