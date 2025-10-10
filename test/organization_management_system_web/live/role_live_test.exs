defmodule OrganizationManagementSystemWeb.RoleLiveTest do
  use OrganizationManagementSystemWeb.ConnCase

  import Phoenix.LiveViewTest

  alias OrganizationManagementSystem.Factory

  @create_attrs %{
    name: "some name",
    scope: "global",
    description: "some description"
  }

  @invalid_attrs %{name: nil, scope: nil, description: nil}

  describe "super user" do
    setup :register_and_log_in_super_user

    defp create_role(%{scope: _scope}) do
      role = Factory.insert!(:role)

      %{role: role}
    end

    setup [:create_role]

    test "lists all roles", %{conn: conn, role: role} do
      {:ok, _index_live, html} = live(conn, ~p"/roles")

      assert html =~ "Listing Roles"
      assert html =~ role.name
    end

    test "saves new role", %{conn: conn} do
      permission = Factory.insert!(:permission, action: "manage user")
      {:ok, index_live, _html} = live(conn, ~p"/roles")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Role")
               |> render_click()
               |> follow_redirect(conn, ~p"/roles/new")

      assert render(form_live) =~ "New Role"

      invalid_attrs = Map.put(@invalid_attrs, :scope, "global")

      assert form_live
             |> form("#role-form", role: invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      attrs = Map.put(@create_attrs, :permission_id, permission.id)

      assert {:ok, index_live, _html} =
               form_live
               |> form("#role-form", role: attrs)
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
  end

  describe "non super user" do
    setup :register_and_log_in_user

    test "cannot access index page", %{conn: conn} do
      assert {:error,
              {:redirect,
               %{
                 to: "/dashboard",
                 flash: %{"error" => "You are not authorized to access this page."}
               }}} =
               live(conn, ~p"/roles")
    end
  end
end
