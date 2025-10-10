defmodule OrganizationManagementSystem.Repo.Migrations.CreateUserRoles do
  use Ecto.Migration

  def change do
    create table(:user_roles) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :role_id, references(:roles, on_delete: :delete_all), null: false
      add :scope, :string, null: false
      add :organisation_id, references(:organisations, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_roles, [:user_id, :role_id, :organisation_id])
  end
end
