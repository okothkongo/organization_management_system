defmodule OrganizationManagementSystem.Accounts.Abilities do
  def can_create_role?(current_user) do
    current_user.is_super_user?
  end
end
