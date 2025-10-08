defmodule OrganizationManagementSystemWeb.UserLive.Index do
  use OrganizationManagementSystemWeb, :live_view

  alias OrganizationManagementSystem.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Roles
        <:actions>
          <.button variant="primary" navigate={~p"/users/register"}>
            <.icon name="hero-plus" /> Invite User
          </.button>
        </:actions>
      </.header>

      <.table
        id="roles"
        rows={@streams.users}
      >
        <:col :let={{_id, user}} label="Name">{user.name}</:col>
        <:col :let={{_id, user}} label="Email">{user.email}</:col>
        <:action :let={{_id, user}}>
          <.link
            phx-click="review"
            phx-value-id={user.id}
            data-confirm="Are you sure you want to review this user?"
            class="btn btn-sm btn-danger ml-2"
          >
            <.icon name="hero-trash" class="w-4 h-4" /> Review
          </.link>
          <.link
            phx-click="approve"
            phx-value-id={user.id}
            data-confirm="Are you sure you want to approve this user?"
            class="btn btn-sm btn-danger ml-2"
          >
            <.icon name="hero-trash" class="w-4 h-4" /> Approve
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "List Users")
     |> stream(:users, Accounts.list_users())}
  end

  @impl true
  def handle_event("approve", %{"id" => user_id}, socket) do
    current_scope = socket.assigns.current_scope
    permission = Accounts.get_permission_by_action!("approve user")

    Accounts.create_user_permission(
      %{permission_id: permission.id, user_id: user_id},
      current_scope
    )

    {:noreply, socket}
  end

  def handle_event("review", %{"id" => user_id}, socket) do
    current_scope = socket.assigns.current_scope
    permission = Accounts.get_permission_by_action!("review user")

    Accounts.create_user_permission(
      %{permission_id: permission.id, user_id: user_id},
      current_scope
    )

    {:noreply, socket}
  end
end
