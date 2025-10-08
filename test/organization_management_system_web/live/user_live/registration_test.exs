defmodule OrganizationManagementSystemWeb.UserLive.RegistrationTest do
  use OrganizationManagementSystemWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import OrganizationManagementSystem.AccountsFixtures
  alias OrganizationManagementSystem.Factory

  describe "Registration page" do
    test "non logged in user", %{conn: conn} do
      assert {:error,
              {:redirect,
               %{
                 to: "/users/log-in",
                 flash: %{"error" => "You must log in to access this page."}
               }}} = live(conn, ~p"/users/register")
    end

    test "renders registration page for super user", %{conn: conn} do
      super_user = Factory.insert!(:super_user)
      conn = log_in_user(conn, super_user)

      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "Invite User"
    end

    test "does not renders registration page for non super user", %{conn: conn} do
      user = Factory.insert!(:user)
      conn = log_in_user(conn, user)

      assert {:error,
              {:redirect,
               %{
                 to: "/dashboard",
                 flash: %{"error" => "You are not authorized to access this page."}
               }}} = live(conn, ~p"/users/register")
    end

    test "renders errors for invalid data", %{conn: conn} do
      super_user = Factory.insert!(:super_user)
      conn = log_in_user(conn, super_user)
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(user: %{"email" => "with spaces"})

      assert result =~ "Invite User"
      assert result =~ "must have the @ sign and no spaces"
    end
  end

  describe "register user" do
    setup %{conn: conn} do
      super_user = Factory.insert!(:super_user)
      %{conn: log_in_user(conn, super_user)}
    end

    test "creates account", %{conn: conn} do
      role = Factory.insert!(:role)
      permission = Factory.insert!(:permission)
      Factory.insert!(:role_permission, role: role, permission: permission)
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      email = unique_user_email()
      attrs = valid_user_attributes(email: email)
      valid_user_attributes = Map.put(attrs, :role_id, role.id)
      form = form(lv, "#registration_form", user: valid_user_attributes)

      {:ok, _lv, html} =
        form
        |> render_submit()
        |> follow_redirect(conn, ~p"/users")

      assert html =~
               ~r/An email was sent to .*, please notify the confirm their account/
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      user = user_fixture(%{email: "test@email.com"})

      result =
        lv
        |> form("#registration_form",
          user: %{"email" => user.email}
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end
  end
end
