defmodule OrganizationManagementSystemWeb.OrganisationMemberLive.IndexTest do
  use OrganizationManagementSystemWeb.ConnCase
  import Phoenix.LiveViewTest

  alias OrganizationManagementSystem.Factory

  describe "user without abilites" do
    setup %{conn: conn} do
      user = Factory.insert!(:user)
      org = Factory.insert!(:organization)

      Factory.insert!(:organization_user,
        user: user,
        organisation: org
      )

      {:ok, logged_in_conn: log_in_user(conn, user), org: org}
    end

    test "non logged in user is redirected to login page", %{conn: conn} do
      {:error, {:redirect, %{to: path}}} = live(conn, ~p"/organisations/members?#{[org_id: 1]}")
      assert path == ~p"/users/log-in"
    end

    test "does not show add member button to member without permissions", %{
      logged_in_conn: conn,
      org: org
    } do
      {:ok, _view, html} = live(conn, ~p"/organisations/members?#{[org_id: org.id]}")
      assert html =~ "Listing Organisations Memberships"
      refute html =~ "Add Member"
    end

    test "member without permissions cannot access new member page", %{
      logged_in_conn: conn,
      org: org
    } do
      {:error, {:redirect, %{to: path}}} =
        live(conn, ~p"/organisations/members/new?#{[org_id: org.id]}")

      assert path == ~p"/dashboard"
    end
  end

  describe "user with abilities" do
    setup do
      user_who_can_add_member = Factory.insert!(:user)
      org = Factory.insert!(:organization)
      role = Factory.insert!(:role, scope: :organisation, name: "Add Member")

      Factory.insert!(:organization_user,
        user: user_who_can_add_member,
        organisation: org
      )

      permission = Factory.insert!(:permission, action: "org:member:add")
      Factory.insert!(:role_permission, role: role, permission: permission)
      Factory.insert!(:user_role, user: user_who_can_add_member, role: role)
      %{org: org, user_who_can_add_member: user_who_can_add_member}
    end

    test "to add member", %{
      conn: conn,
      org: org,
      user_who_can_add_member: user_who_can_add_member
    } do
      conn = log_in_user(conn, user_who_can_add_member)
      user = Factory.insert!(:user)
      role = Factory.insert!(:role, scope: :organisation, organisation: org)
      {:ok, view, _html} = live(conn, ~p"/organisations/members?#{[org_id: org.id]}")

      view
      |> element("a", "Add Member")
      |> render_click()

      assert_redirect(view, ~p"/organisations/members/new?#{[org_id: org.id]}")

      {:ok, view, _} = live(conn, ~p"/organisations/members/new?#{[org_id: org.id]}")

      {:ok, _lv, html} =
        view
        |> form("#member-form", %{
          "organization_user" => %{
            "user_id" => user.id,
            "role_id" => role.id
          }
        })
        |> render_submit()
        |> follow_redirect(conn, ~p"/organisations/members?#{[org_id: org.id]}")

      assert html =~ "member  successfully invited"
      assert html =~ user.name
    end

    test "Sof super admin", %{conn: conn, org: org} do
      super_user = Factory.insert!(:super_user)
      conn = log_in_user(conn, super_user)
      user = Factory.insert!(:user)
      role = Factory.insert!(:role, scope: :organisation, organisation: org)
      {:ok, view, _html} = live(conn, ~p"/organisations/members?#{[org_id: org.id]}")

      view
      |> element("a", "Add Member")
      |> render_click()

      assert_redirect(view, ~p"/organisations/members/new?#{[org_id: org.id]}")

      {:ok, view, _} = live(conn, ~p"/organisations/members/new?#{[org_id: org.id]}")

      {:ok, _lv, html} =
        view
        |> form("#member-form", %{
          "organization_user" => %{
            "user_id" => user.id,
            "role_id" => role.id
          }
        })
        |> render_submit()
        |> follow_redirect(conn, ~p"/organisations/members?#{[org_id: org.id]}")

      assert html =~ "member  successfully invited"
      assert html =~ user.name
    end
  end
end
