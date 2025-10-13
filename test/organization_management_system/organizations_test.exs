defmodule OrganizationManagementSystem.OrganizationsTest do
  alias Hex.API.Key.Organization
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

    test "list_user_organisations/1 returns all organisations where user is member" do
      user = Factory.insert!(:user)
      org = Factory.insert!(:organization)
      org2 = Factory.insert!(:organization)
      org3 = Factory.insert!(:organization)

      Factory.insert!(:organization_user,
        user: user,
        organisation: org
      )

      Factory.insert!(:organization_user,
        user: user,
        organisation: org2
      )

      assert user_orgs = Organizations.list_user_organisations(user)
      assert length(user_orgs) == 2
      assert Enum.any?(user_orgs, fn o -> o.id == org.id end)
      assert Enum.any?(user_orgs, fn o -> o.id == org2.id end)
      refute Enum.any?(user_orgs, fn o -> o.id == org3.id end)
    end

    test "list_user_organisations/1 returns all organisations for super user" do
      user = Factory.insert!(:super_user)
      org = Factory.insert!(:organization)
      org2 = Factory.insert!(:organization)
      org3 = Factory.insert!(:organization)

      assert user_orgs = Organizations.list_user_organisations(user)
      assert length(user_orgs) >= 3
      assert Enum.any?(user_orgs, fn o -> o.id == org.id end)
      assert Enum.any?(user_orgs, fn o -> o.id == org2.id end)
      assert Enum.any?(user_orgs, fn o -> o.id == org3.id end)
    end

    test "member_of_org?/2 returns true if user is member of the org" do
      user = Factory.insert!(:user)
      org = Factory.insert!(:organization)

      Factory.insert!(:organization_user,
        user: user,
        organisation: org
      )

      assert Organizations.member_of_org?(user.id, org.id) == true
    end

    test "member_of_org?/2 returns false if user is not member of the org" do
      user = Factory.insert!(:user)
      org = Factory.insert!(:organization)

      assert Organizations.member_of_org?(user.id, org.id) == false
    end

    test "user_has_role_in_org?/2 returns true if user has a role in the org" do
      user = Factory.insert!(:user)
      org = Factory.insert!(:organization)

      Factory.insert!(:organization_user,
        user: user,
        organisation: org
      )

      Factory.insert!(:user_role,
        user: user,
        organisation: org,
        scope: :organisation
      )

      assert Organizations.user_has_role_in_org?(user.id, org.id) == true
    end

    test "user_has_role_in_org?/2 returns false if user has no role in the org" do
      user = Factory.insert!(:user)
      org = Factory.insert!(:organization)

      Factory.insert!(:organization_user,
        user: user,
        organisation: org
      )

      assert Organizations.user_has_role_in_org?(user.id, org.id) == false
    end

    test "user_has_role_in_org?/2 returns false if user is not member of the org" do
      user = Factory.insert!(:user)
      org = Factory.insert!(:organization)

      assert Organizations.user_has_role_in_org?(user.id, org.id) == false
    end

    test "list_organization_members/1 returns all members of the org" do
      user1 = Factory.insert!(:user)
      user2 = Factory.insert!(:user)
      user3 = Factory.insert!(:user)
      org = Factory.insert!(:organization)

      Factory.insert!(:organization_user,
        user: user1,
        organisation: org
      )

      Factory.insert!(:organization_user,
        user: user2,
        organisation: org
      )

      assert members = Organizations.list_organization_members(org.id)
      assert length(members) == 2
      assert Enum.any?(members, fn m -> m.id == user1.id end)
      assert Enum.any?(members, fn m -> m.id == user2.id end)
      refute Enum.any?(members, fn m -> m.id == user3.id end)
    end

    test "list_organization_members/1 returns empty list if org does not exist" do
      assert [] = Organizations.list_organization_members(-1)
    end

    test "list_roles_by_organization/1 returns all roles of the org" do
      org = Factory.insert!(:organization)
      role1 = Factory.insert!(:role, scope: :organisation, organisation: org)
      role2 = Factory.insert!(:role, scope: :organisation, organisation: org)
      _role3 = Factory.insert!(:role, scope: :global)

      assert roles = Organizations.list_roles_by_organization(org.id)
      assert length(roles) == 2
      assert Enum.any?(roles, fn r -> r.id == role1.id end)
      assert Enum.any?(roles, fn r -> r.id == role2.id end)
    end

    test "list_roles_by_organization/1 returns empty list if org has no roles" do
      org = Factory.insert!(:organization)
      assert [] = Organizations.list_roles_by_organization(org.id)
    end
  end

  describe "delete_organization_member_role/2" do
    setup do
      org = Factory.insert!(:organization)
      org2 = Factory.insert!(:organization)

      user_member1 = Factory.insert!(:user)
      user_member2 = Factory.insert!(:user)
      non_member = Factory.insert!(:user)
      global_user = Factory.insert!(:user)

      org_role = Factory.insert!(:user_role, user: user_member1, organisation: org)
      org_role2 = Factory.insert!(:user_role, user: user_member2, organisation: org)
      non_role = Factory.insert!(:user_role, user: non_member, organisation: org2)
      global_role = Factory.insert!(:user_role, user: global_user)

      _org_member = Factory.insert!(:organization_user, user: user_member1, organisation: org)
      _org_member2 = Factory.insert!(:organization_user, user: user_member2, organisation: org)
      _non_member = Factory.insert!(:organization_user, user: user_member1, organisation: org2)

      %{
        org_role: org_role,
        org_role2: org_role2,
        non_role: non_role,
        global_role: global_role,
        org: org,
        user_member1: user_member1
      }
    end

    test "delete only role of user for given organisation", context do
      %{
        org_role: org_role,
        org_role2: org_role2,
        non_role: non_role,
        global_role: global_role,
        org: org,
        user_member1: user_member1
      } = context

      assert {1, _} = Organizations.delete_organization_member_role(user_member1.id, org.id)
      user_roles = Repo.all(OrganizationManagementSystem.Accounts.UserRole)
      user_role_ids = Enum.map(user_roles, fn user_role -> user_role.id end)
      refute org_role.id in user_role_ids
      assert org_role2.id in user_role_ids
      assert non_role.id in user_role_ids
      assert global_role.id in user_role_ids
    end
  end
end
