defmodule OrganizationManagementSystemWeb.RoleLiveTest do
  use OrganizationManagementSystemWeb.ConnCase

  import Phoenix.LiveViewTest
  import OrganizationManagementSystem.AccountsFixtures

  @create_attrs %{
    name: "some name",
    scope: "all",
    description: "some description",
    system?: true
  }

  @invalid_attrs %{name: nil, scope: nil, description: nil, system?: false}

  describe "super user" do
    setup :register_and_log_in_super_user

    defp create_role(%{scope: scope}) do
      role = role_fixture(scope)

      %{role: role}
    end

    setup [:create_role]

    test "lists all roles", %{conn: conn, role: role} do
      {:ok, _index_live, html} = live(conn, ~p"/roles")

      assert html =~ "Listing Roles"
      assert html =~ role.name
    end

    test "saves new role", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/roles")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Role")
               |> render_click()
               |> follow_redirect(conn, ~p"/roles/new")

      assert render(form_live) =~ "New Role"

      invalid_attrs = Map.put(@invalid_attrs, :scope, "all")

      assert form_live
             |> form("#role-form", role: invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#role-form", role: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/roles")

      html = render(index_live)
      assert html =~ "Role created successfully"
      assert html =~ "some name"
    end

    test "displays role", %{conn: conn, role: role} do
      {:ok, _show_live, html} = live(conn, ~p"/roles/#{role}")

      assert html =~ "Show Role"
      assert html =~ role.name
    end

    test "deletes role in listing", %{conn: conn, role: role} do
      {:ok, index_live, _html} = live(conn, ~p"/roles")

      assert index_live |> element("#roles-#{role.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#roles-#{role.id}")
    end
  end

  describe "non super user" do
    setup :register_and_log_in_user

    test "cannot access index page", %{conn: conn} do
      assert {:error,
              {:redirect,
               %{to: "/", flash: %{"error" => "You are not authorized to access this page."}}}} =
               live(conn, ~p"/roles")
    end
  end
end
