defmodule OrganizationManagementSystem.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset

  alias OrganizationManagementSystem.Accounts.Permission
  alias OrganizationManagementSystem.Accounts.RolePermission
  alias OrganizationManagementSystem.Accounts.User

  schema "roles" do
    field :name, :string
    field :scope, Ecto.Enum, values: [:organisation, :all]
    field :description, :string
    field :system?, :boolean, default: false
    belongs_to :created_by, User, foreign_key: :created_by_id
    many_to_many :permissions, Permission, join_through: RolePermission

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(role, attrs, scope) do
    role
    |> cast(attrs, [:name, :scope, :description, :system?])
    |> validate_required([:name, :scope, :description, :system?])
    |> put_change(:created_by_id, scope.user.id)
  end
end
