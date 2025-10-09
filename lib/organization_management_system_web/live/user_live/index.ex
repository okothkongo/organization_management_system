defmodule OrganizationManagementSystemWeb.UserLive.Index do
  use OrganizationManagementSystemWeb, :live_view

  alias OrganizationManagementSystem.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Users
        <:actions>
          <%= if @current_scope.user.is_super_user? do %>
            <.button variant="primary" navigate={~p"/users/register"}>
              <.icon name="hero-plus" /> Invite User
            </.button>
          <% end %>
        </:actions>
      </.header>

      <.table
        id="roles"
        rows={@streams.users}
      >
        <:col :let={{_id, user}} label="Name">{user.name}</:col>
        <:col :let={{_id, user}} label="Email">{user.email}</:col>
        <:action :let={{_id, user}}>
          <%= unless user.is_super_user? do %>
            <%= cond do %>
              <% user.status == :invited -> %>
                <.link
                  phx-click="review"
                  phx-value-id={user.id}
                  data-confirm="Are you sure you want to review this user?"
                  class="btn btn-sm btn-danger ml-2"
                >
                  <.icon name="hero-eye" class="w-4 h-4" /> Review
                </.link>
              <% user.status == :reviewed -> %>
                <.link
                  phx-click="approve"
                  phx-value-id={user.id}
                  data-confirm="Are you sure you want to approve this user?"
                  class="btn btn-sm btn-success ml-2"
                >
                  <.icon name="hero-check-circle" class="w-4 h-4" /> Approve
                </.link>
              <% true -> %>
            <% end %>
          <% end %>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    {:ok,
     socket
     |> assign(:page_title, "List Users")
     |> stream(:users, Accounts.list_users(scope))}
  end

  @impl true
  def handle_event("approve", %{"id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    Accounts.update_user(user, %{status: :approved})

    {:noreply, push_navigate(socket, to: ~p"/users")}
  end

  def handle_event("review", %{"id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    Accounts.update_user(user, %{status: :reviewed})

    {:noreply, push_navigate(socket, to: ~p"/users")}
  end
end
