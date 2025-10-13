defmodule OrganizationManagementSystem.Repo.Migrations.EnsuerGlobalRoleIsUnique do
  use Ecto.Migration

  def change do
    drop unique_index(:user_roles, [:user_id, :role_id, :organisation_id])

    create unique_index(:user_roles, [:user_id, :role_id, :organisation_id],
             name: :user_roles_with_org_unique_index,
             where: "organisation_id IS NOT NULL"
           )

    create unique_index(:user_roles, [:user_id, :role_id],
             name: :user_roles_without_org_unique_index,
             where: "organisation_id IS NULL"
           )
  end
end
