defmodule OrganizationManagementSystem.OrganizationsTest do
  alias OrganizationManagementSystem.Factory
  use OrganizationManagementSystem.DataCase

  alias OrganizationManagementSystem.Organizations

  describe "organisations" do
    alias OrganizationManagementSystem.Organizations.Organization

    import OrganizationManagementSystem.AccountsFixtures, only: [user_scope_fixture: 0]
    import OrganizationManagementSystem.OrganizationsFixtures

    @invalid_attrs %{name: nil}

    test "list_organisations/0 returns all scoped organisations" do
      organization = Factory.insert!(:organization)

      assert [organization_listed] = Organizations.list_organisations()
      assert organization.id == organization_listed.id
    end

    test "create_organization/2 with valid data creates a organization" do
      valid_attrs = %{name: "some name"}
      scope = user_scope_fixture()

      assert {:ok, %Organization{} = organization} =
               Organizations.create_organization(scope, valid_attrs)

      assert organization.name == "some name"
      assert organization.created_by_id == scope.user.id
    end

    test "create_organization/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Organizations.create_organization(scope, @invalid_attrs)
    end

    test "change_organization/2 returns a organization changeset" do
      scope = user_scope_fixture()
      organization = organization_fixture(scope)
      assert %Ecto.Changeset{} = Organizations.change_organization(scope, organization)
    end
  end
end
