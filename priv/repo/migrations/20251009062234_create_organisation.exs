defmodule OrganizationManagementSystem.Repo.Migrations.CreateOrganisation do
  use Ecto.Migration

  def change do
    create table(:organisations) do
      add :name, :string
      add :created_by_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:organisations, [:created_by_id])
  end
end
