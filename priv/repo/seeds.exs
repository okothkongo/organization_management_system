# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     OrganizationManagementSystem.Repo.insert!(%OrganizationManagementSystem.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias OrganizationManagementSystem.Repo
alias OrganizationManagementSystem.Accounts.User

Repo.insert!(%User{
  email: "admin@example.com",
  name: "Super Admin",
  status: :approved,
  is_super_user?: true
})
