defmodule OrganizationManagementSystemWeb.UserLive.IndexTest do
  use OrganizationManagementSystemWeb.ConnCase
  import Phoenix.LiveViewTest
  import OrganizationManagementSystem.AccountsFixtures
  alias OrganizationManagementSystem.Accounts
  alias OrganizationManagementSystem.Factory

  describe "User listing and actions" do
    setup %{conn: conn} do
      invited_user = user_fixture(%{status: :invited, name: "Invited User"})
      reviewed_user = user_fixture(%{status: :reviewed, name: "Reviewed User"})
      approved_user = user_fixture(%{status: :approved, name: "Approved User"})
      super_user = user_fixture(%{is_super_user?: true, name: "Super User"})

      %{
        conn: conn,
        invited_user: invited_user,
        reviewed_user: reviewed_user,
        approved_user: approved_user,
        super_user: super_user
      }
    end

    test "super user sees all users and can invite", %{conn: conn, super_user: super_user} do
      conn = log_in_user(conn, super_user)
      {:ok, _view, html} = live(conn, ~p"/users")
      assert html =~ "Listing Users"
      assert html =~ "Invite User"
      assert html =~ super_user.name
    end

    test "reviewer sees only invited users and can review", %{
      conn: conn,
      invited_user: invited_user
    } do
      reviewer = Factory.insert!(:user)
      global_role = Factory.insert!(:role, scope: :all, name: "user_reviewer")

      permission = Factory.insert!(:permission, action: "review:stage:invited")
      Factory.insert!(:role_permission, role: global_role, permission: permission)
      Factory.insert!(:user_permission, user: reviewer, permission: permission)
      conn = log_in_user(conn, reviewer)
      {:ok, view, html} = live(conn, ~p"/users")
      assert html =~ invited_user.name
      refute html =~ "Approve"
      assert html =~ "Review"

      view
      |> element(~s([phx-click='review'][phx-value-id='#{invited_user.id}']))
      |> render_click()

      updated_user = Accounts.get_user!(invited_user.id)
      assert updated_user.status == :reviewed
    end

    test "approver sees only reviewed users and can approve", %{
      conn: conn,
      reviewed_user: reviewed_user
    } do
      approver = Factory.insert!(:user)
      global_role = Factory.insert!(:role, scope: :all, name: "user_approver")

      permission = Factory.insert!(:permission, action: "review:stage:reviewed")
      Factory.insert!(:role_permission, role: global_role, permission: permission)
      Factory.insert!(:user_permission, user: approver, permission: permission)

      conn = log_in_user(conn, approver)
      {:ok, view, html} = live(conn, ~p"/users")
      assert html =~ reviewed_user.name
      assert html =~ "Approve"
      #  refute html =~ "Review"

      # Simulate clicking approve
      view
      |> element(~s([phx-click="approve"][phx-value-id="#{reviewed_user.id}"]))
      |> render_click()

      updated_user = Accounts.get_user!(reviewed_user.id)
      assert updated_user.status == :approved
    end
  end
end
