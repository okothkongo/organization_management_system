defmodule OrganizationManagementSystemWeb.RoleLive.Show do
  use OrganizationManagementSystemWeb, :live_view

  alias OrganizationManagementSystem.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Role {@role.id}
        <:subtitle>This is a role record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/roles"}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@role.name}</:item>
        <:item title="Scope">{@role.scope}</:item>
        <:item title="Description">{@role.description}</:item>

      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Accounts.subscribe_roles(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Role")
     |> assign(:role, Accounts.get_role!(id))}
  end

  @impl true
  def handle_info(
        {:updated, %OrganizationManagementSystem.Accounts.Role{id: id} = role},
        %{assigns: %{role: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :role, role)}
  end

  def handle_info({type, %OrganizationManagementSystem.Accounts.Role{}}, socket)
      when type in [:created, :updated] do
    {:noreply, socket}
  end
end
