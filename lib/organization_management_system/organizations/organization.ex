defmodule OrganizationManagementSystem.Organizations.Organization do
  @moduledoc """
  The Organization schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "organisations" do
    field :name, :string
    belongs_to :created_by, OrganizationManagementSystem.Accounts.User

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
