defmodule OrganizationManagementSystem.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset

  alias OrganizationManagementSystem.Accounts.Permission
  alias OrganizationManagementSystem.Accounts.RolePermission

  schema "roles" do
    field :name, :string
    field :scope, :string
    field :description, :string
    field :system?, :boolean, default: false
    many_to_many :permissions, Permission, join_through: RolePermission

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :scope, :description, :system?])
    |> validate_required([:name, :scope, :description, :system?])
  end
end
