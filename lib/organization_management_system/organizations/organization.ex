defmodule OrganizationManagementSystem.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  schema "organisations" do
    field :name, :string
    field :created_by_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs, user_scope) do
    organization
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_change(:created_by_id, user_scope.user.id)
  end
end
