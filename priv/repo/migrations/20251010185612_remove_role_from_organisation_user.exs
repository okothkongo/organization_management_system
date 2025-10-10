defmodule OrganizationManagementSystem.Repo.Migrations.RemoveRoleFromOrganisationUser do
  use Ecto.Migration

  def change do
    drop index(:organisation_users, [:role_id])

    alter table(:organisation_users) do
      remove :role_id
    end
  end
end
