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

super_user =
  Repo.insert!(%User{
    email: "admin@example.com",
    name: "Super Admin",
    status: :approved,
    is_super_user?: true
  })

Repo.insert!(%Permission{
  action: "priviledged:access",
  description: "Can  create and other operations on org"
})



Repo.insert!(%Permission{
  action: "org:member:add",
  description: "Can  add organistaton member"
})

Repo.insert!(%Permission{
  action: "org:member:grant_role",
  description: "Can  grant role to organistaton members"
})

Repo.insert!(%Permission{
  action: "review:stage:invited",
  description: "Can review invited users"
})

Repo.insert!(%Permission{
  action: "review:stage:reviewed",
  description: "Can approve reviewed users"
})
