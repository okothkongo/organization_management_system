defmodule OrganizationManagementSystem.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string
      add :scope, :string
      add :description, :string
      add :system?, :boolean, default: false, null: false
      add :created_by_id, references(:users, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:roles, [:created_by_id])
  end
end
