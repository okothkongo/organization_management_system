defmodule OrganizationManagementSystem.Repo.Migrations.AddIsSuperUserFieldToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_super_user?, :boolean, default: false, null: false
    end
  end
end
