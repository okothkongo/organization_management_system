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
          <%= case {user.is_super_user?, user.status} do %>
            <% {false, :invited} -> %>
              <.link
                phx-click="review"
                phx-value-id={user.id}
                data-confirm="Are you sure you want to review this user?"
                class="btn btn-sm btn-danger ml-2"
              >
                <.icon name="hero-eye" class="w-4 h-4" /> Review
              </.link>
            <% {false, :reviewed} -> %>
              <.link
                phx-click="approve"
                phx-value-id={user.id}
                data-confirm="Are you sure you want to approve this user?"
                class="btn btn-sm btn-success ml-2"
              >
                <.icon name="hero-check-circle" class="w-4 h-4" /> Approve
              </.link>
            <% _ -> %>
          <% end %>

          <%= if @current_scope.user.is_super_user? and has_no_global_role?(user.id) and !user.is_super_user? do %>
            <select
              id={"role-select-#{user.id}"}
              phx-click="grant_role"
              phx-value-id={user.id}
            >
              <option value="">Assign Role</option>
              <%= for {label, value} <- list_roles() do %>
                <option value={value}>{label}</option>
              <% end %>
            </select>
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
     |> stream(:users, list_users(scope))}
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

  def handle_event("grant_role", params, socket) do
    scope = socket.assigns.current_scope

    user_id = params["id"]

    role_id = params["value"]

    case Accounts.assign_role_to_user(user_id, role_id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> stream(:users, list_users(scope), reset: true)
         |> put_flash(:info, "Role assigned successfully")
         |> push_navigate(to: ~p"/users")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "User already has the role")}
    end
  end

  defp list_roles do
    Accounts.list_global_roles()
    |> Enum.map(&{&1.name, &1.id})
  end

  defp has_no_global_role?(user_id) do
    !Accounts.user_has_global_role?(user_id)
  end

  defp list_users(scope) do
    Accounts.list_users(scope)
  end
end
