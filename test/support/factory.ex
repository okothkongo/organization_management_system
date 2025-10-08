defmodule OrganizationManagementSystem.Factory do
  @moduledoc """
  Test data factory for OrganizationManagementSystem.

  Provides simple functions for building and inserting test data for use in tests.
  Use `build/1` to create a struct without persisting, and `insert!/1` to insert into the database.

  ## Examples

      iex> Factory.build(:permission)
      %OrganizationManagementSystem.Accounts.Permission{...}

      iex> Factory.insert!(:permission)
      %OrganizationManagementSystem.Accounts.Permission{...}

      iex> Factory.build(:permission, action: "manage user")
      %OrganizationManagementSystem.Accounts.Permission{action: "manage user", ...}

  """
  alias OrganizationManagementSystem.Accounts.Permission
  alias OrganizationManagementSystem.Accounts.RolePermission
  alias OrganizationManagementSystem.Accounts.User
  alias OrganizationManagementSystem.Accounts.Role
  alias OrganizationManagementSystem.Repo

  def build(:permission) do
    %Permission{
      action: "review user",
      description: "review user"
    }
  end

  def build(:super_user) do
    %User{
      email: "user#{System.unique_integer()}@example.com",
      name: "John Doe",
      is_super_user?: true
    }
  end

  def build(:user) do
    %User{
      email: "user#{System.unique_integer()}@example.com",
      name: "John Doe"
    }
  end

  def build(:role) do
    %Role{
      name: "user_reviewer",
      created_by: build(:super_user),
      description: "some role",
      scope: :all
    }
  end

  def build(:role_permission) do
    %RolePermission{
      role: build(:role),
      permission: build(:permission)
    }
  end

  # Convenience API

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
