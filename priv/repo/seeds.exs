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
alias OrganizationManagementSystem.Accounts.Role
alias OrganizationManagementSystem.Accounts.RolePermission

super_user =
  Repo.insert!(%User{
    email: "admin@example.com",
    name: "Super Admin",
    status: :approved,
    is_super_user?: true
  })

Repo.insert!(%Permission{
  action: "review user",
  description: "can review user"
})

Repo.insert!(%Permission{
  action: "approve user",
  description: "Can reviewed approve user"
})

Repo.insert!(%Role{
  name: "user_approver",
  description: "Role for approving users",
  created_by_id: super_user.id,
  scope: all
})

Repo.insert!(%Role{
  name: "user_reviewer",
  description: "Role for reviewing users",
  created_by_id: super_user.id,
  scope: :all
})

Repo.insert!(%RolePermission{
  role_id: Repo.get_by!(Role, name: "user_approver").id,
  permission_id: Repo.get_by!(Permission, action: "approve user").id
})

Repo.insert!(%RolePermission{
  role_id: Repo.get_by!(Role, name: "user_reviewer").id,
  permission_id: Repo.get_by!(Permission, action: "review user").id
})

Enum.each(1..10, fn i ->
  Repo.insert!(%User{
    email: "user#{i}@example.com",
    name: "User #{i}",
    status: :approved,
    is_super_user?: false
  })
end)
