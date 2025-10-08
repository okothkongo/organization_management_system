defmodule OrganizationManagementSystem.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :action, :string
      add :description, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:permissions, [:action])
  end
end
