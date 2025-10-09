defmodule OrganizationManagementSystem.Repo.Migrations.CreateOrganizationUsers do
  use Ecto.Migration

  def change do
    create table(:organisation_users) do
      add :organisation_id, references(:organisations, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :invited_by_id, references(:users, on_delete: :nothing)
      add :role_id, references(:roles, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:organisation_users, [:organisation_id])
    create index(:organisation_users, [:user_id])
    create index(:organisation_users, [:invited_by_id])
    create unique_index(:organisation_users, [:organisation_id, :user_id])
    create index(:organisation_users, [:role_id])
  end
end
