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
    @priviledged_permission "priviledged:access"
    setup do
      priviledged = Factory.insert!(:user)
      permission = Factory.insert!(:permission, action: @priviledged_permission)
      role = Factory.insert!(:role, scope: :global, name: "Creator")

      Factory.insert!(:role_permission, role: role, permission: permission)

      Factory.insert!(:user_role, user: priviledged, role: role)

      %{priviledged: priviledged}
    end

    test "privilelged user create organization", %{
      conn: conn,
      priviledged: priviledged
    } do
      conn = log_in_user(conn, priviledged)
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

    test "super user can edit organization", %{
      conn: conn
    } do
      super_user = Factory.insert!(:super_user)
      conn = log_in_user(conn, super_user)
      organization = Factory.insert!(:organization)
      {:ok, index_live, _html} = live(conn, ~p"/organisations")

      assert {:ok, edit_form_live, _} =
               index_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/organisations/#{organization.id}/edit")

      assert render(edit_form_live) =~ "Edit Organization"

      assert {:ok, _index_live, html} =
               edit_form_live
               |> form("#organization-form", organization: %{name: "updated name"})
               |> render_submit()
               |> follow_redirect(conn, ~p"/organisations")

      assert html =~ "Organization updated successfully"
      assert html =~ "updated name"
    end

    test "priviledged user can edit organization", %{
      conn: conn,
      priviledged: priviledged
    } do
      conn = log_in_user(conn, priviledged)

      organization = Factory.insert!(:organization)
      {:ok, index_live, _html} = live(conn, ~p"/organisations")

      assert {:ok, edit_form_live, _} =
               index_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/organisations/#{organization.id}/edit")

      assert render(edit_form_live) =~ "Edit Organization"

      assert {:ok, _index_live, html} =
               edit_form_live
               |> form("#organization-form", organization: %{name: "updated name"})
               |> render_submit()
               |> follow_redirect(conn, ~p"/organisations")

      assert html =~ "Organization updated successfully"
      assert html =~ "updated name"
    end
  end
end
