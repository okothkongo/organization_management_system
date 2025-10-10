defmodule OrganizationManagementSystem.Repo.Migrations.DropUserPermissionTable do
  use Ecto.Migration

  def change do
    drop table(:user_permissions)
  end
end
