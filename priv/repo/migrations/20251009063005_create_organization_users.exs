defmodule OrganizationManagementSystem.Repo.Migrations.CreateOrganizationUsers do
  use Ecto.Migration

  def change do
    create table(:organization_users) do
      add :organization_id, references(:organizations, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :invited_by_id, references(:users, on_delete: :nothing)
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:organization_users, [:user_id])

    create index(:organization_users, [:organization_id])
    create index(:organization_users, [:user_id])
    create index(:organization_users, [:invited_by_id])
  end
end
