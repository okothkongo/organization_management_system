defmodule :"Elixir.OrganizationManagementSystem.Repo.Migrations.RemoveSytem?FromRole" do
  use Ecto.Migration

  def change do
    alter table(:roles) do
      remove :system?
    end
  end
end
