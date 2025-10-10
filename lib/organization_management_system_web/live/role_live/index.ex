defmodule OrganizationManagementSystemWeb.RoleLive.Index do
  use OrganizationManagementSystemWeb, :live_view

  alias OrganizationManagementSystem.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Roles
        <:actions>
          <.button variant="primary" navigate={~p"/roles/new"}>
            <.icon name="hero-plus" /> New Role
          </.button>
        </:actions>
      </.header>

      <.table
        id="roles"
        rows={@streams.roles}
        row_click={fn {_id, role} -> JS.navigate(~p"/roles/#{role}") end}
      >
        <:col :let={{_id, role}} label="Name">{role.name}</:col>
        <:col :let={{_id, role}} label="Scope">{role.scope}</:col>
        <:col :let={{_id, role}} label="Description">{role.description}</:col>

        <:action :let={{_id, role}}>
          <div class="sr-only">
            <.link navigate={~p"/roles/#{role}"}>Show</.link>
          </div>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    # if connected?(socket) do
    #   Accounts.subscribe_roles(socket.assigns.current_scope)
    # end

    {:ok,
     socket
     |> assign(:page_title, "Listing Roles")
     |> stream(:roles, list_roles())}
  end

  defp list_roles do
    Accounts.list_roles()
  end
end
