defmodule OrganizationManagementSystemWeb.OrganizationLiveTest do
  use OrganizationManagementSystemWeb.ConnCase

  import Phoenix.LiveViewTest
  import OrganizationManagementSystem.OrganizationsFixtures

  @create_attrs %{name: "some name"}

  @invalid_attrs %{name: nil}

  setup :register_and_log_in_user

  defp create_organization(%{scope: scope}) do
    organization = organization_fixture(scope)

    %{organization: organization}
  end

  describe "Index" do
    setup [:create_organization]

    test "lists all organisations", %{conn: conn, organization: organization} do
      {:ok, _index_live, html} = live(conn, ~p"/organisations")

      assert html =~ "Listing Organisations"
      assert html =~ organization.name
    end

    test "saves new organization", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/organisations")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Organization")
               |> render_click()
               |> follow_redirect(conn, ~p"/organisations/new")

      assert render(form_live) =~ "New Organization"

      assert form_live
             |> form("#organization-form", organization: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#organization-form", organization: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/organisations")

      html = render(index_live)
      assert html =~ "Organization created successfully"
      assert html =~ "some name"
    end
  end
end
