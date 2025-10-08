defmodule OrganizationManagementSystem.Accounts.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
    field :action, :string
    field :description, :string

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
