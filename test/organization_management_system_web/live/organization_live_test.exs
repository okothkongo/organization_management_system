defmodule OrganizationManagementSystemWeb.OrganizationLiveTest do
  use OrganizationManagementSystemWeb.ConnCase

  import Phoenix.LiveViewTest

  alias OrganizationManagementSystem.Factory

  describe "User without abilities" do
    setup do
      user_without_abilities = Factory.insert!(:user)
      %{user_without_abilities: user_without_abilities}
    end

    test "user who is not logged in cannot access organization index", %{
      conn: conn
    } do
      {:error, {:redirect, %{to: path}}} = live(conn, ~p"/organisations")

      assert path == "/users/log-in"
    end

    test "cannot see new organization button", %{
      conn: conn,
      user_without_abilities: user_without_abilities
    } do
      conn = log_in_user(conn, user_without_abilities)
      {:ok, _index_live, html} = live(conn, ~p"/organisations")
      refute html =~ "New Organization"
    end
  end

  describe "User with abilities" do
    setup do
      user_who_can_create_org = Factory.insert!(:user)
      permission = Factory.insert!(:permission, action: "org:create")
      role = Factory.insert!(:role, scope: :organisation, name: "Creator")

      Factory.insert!(:role_permission, role: role, permission: permission)
      Factory.insert!(:user_permission, user: user_who_can_create_org, permission: permission)
      %{user_who_can_create_org: user_who_can_create_org}
    end

    test "to create organization", %{
      conn: conn,
      user_who_can_create_org: user_who_can_create_org
    } do
      conn = log_in_user(conn, user_who_can_create_org)
      {:ok, index_live, html} = live(conn, ~p"/organisations")
      assert html =~ "New Organization"

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Organization")
               |> render_click()
               |> follow_redirect(conn, ~p"/organisations/new")

      assert render(form_live) =~ "New Organization"

      form_live
      |> form("#organization-form", organization: %{name: ""})
      |> render_change() =~ "can&#39;t be blank"

      assert {:ok, _index_live, html} =
               form_live
               |> form("#organization-form", organization: %{name: "some name"})
               |> render_submit()
               |> follow_redirect(conn, ~p"/organisations")

      assert html =~ "Organization created successfully"
      assert html =~ "some name"
    end

    test "super user can create organization", %{
      conn: conn
    } do
      super_user = Factory.insert!(:super_user)
      conn = log_in_user(conn, super_user)
      {:ok, index_live, html} = live(conn, ~p"/organisations")
      assert html =~ "New Organization"

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Organization")
               |> render_click()
               |> follow_redirect(conn, ~p"/organisations/new")

      assert render(form_live) =~ "New Organization"

      form_live
      |> form("#organization-form", organization: %{name: ""})
      |> render_change() =~ "can&#39;t be blank"

      assert {:ok, _index_live, html} =
               form_live
               |> form("#organization-form", organization: %{name: "some name"})
               |> render_submit()
               |> follow_redirect(conn, ~p"/organisations")

      assert html =~ "Organization created successfully"
      assert html =~ "some name"
    end
  end
end
