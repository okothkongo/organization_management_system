defmodule OrganizationManagementSystem.Repo.Migrations.MakeRoleUniquePerOrganisation do
  use Ecto.Migration

  def change do
    alter table(:roles) do
      add :organisation_id, references(:organisations, on_delete: :nothing)
    end

    create unique_index(:roles, [:organisation_id, :name], name: :roles_org_name_idx)

    create unique_index(:roles, [:name],
             name: :roles_global_name_idx,
             where: "organisation_id IS NULL"
           )
  end
end
