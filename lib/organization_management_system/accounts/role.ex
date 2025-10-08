defmodule OrganizationManagementSystem.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :name, :string
    field :scope, :string
    field :decription, :string
    field :system?, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :scope, :decription, :system?])
    |> validate_required([:name, :scope, :decription, :system?])
  end
end
