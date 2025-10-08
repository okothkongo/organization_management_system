defmodule OrganizationManagementSystem.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string
      add :scope, :string
      add :decription, :string
      add :system?, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
