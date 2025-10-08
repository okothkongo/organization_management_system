defmodule OrganizationManagementSystem.Repo.Migrations.CreateUserPermissions do
  use Ecto.Migration

  def change do
    create table(:user_permissions) do
      add :granted_by_id, references(:users, on_delete: :nothing), null: false

      add :permission_id, references(:permissions, on_delete: :nothing), null: false
      add :user_id, references(:users, type: :id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_permissions, [:user_id])

    create index(:user_permissions, [:permission_id])
    create index(:user_permissions, [:granted_by_id])
  end
end
