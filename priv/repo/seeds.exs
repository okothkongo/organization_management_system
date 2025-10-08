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
alias OrganizationManagementSystem.Accounts.Permission

Repo.insert!(%User{
  email: "admin@example.com",
  name: "Super Admin",
  status: :approved,
  is_super_user?: true
})

Repo.insert!(%Permission{
  action: "user reviewer",
  description: "can review user"
})

Repo.insert!(%Permission{
  action: "user approver",
  description: "Can reviewed approve user"
})
