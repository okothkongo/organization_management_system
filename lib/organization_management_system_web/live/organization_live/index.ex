defmodule OrganizationManagementSystemWeb.OrganizationLive.Index do
  use OrganizationManagementSystemWeb, :live_view

  alias OrganizationManagementSystem.Organizations
  alias OrganizationManagementSystem.Organizations.Organization
  alias OrganizationManagementSystem.Accounts.Abilities

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Organisations
        <:actions>
          <.button
            :if={can_create_org?(@current_scope.user)}
            variant="primary"
            navigate={~p"/organisations/new"}
          >
            <.icon name="hero-plus" /> New Organization
          </.button>
        </:actions>
      </.header>

      <.table
        id="organisations"
        rows={@streams.organisations}
      >
        <:col :let={{_id, organization}} label="Name">{organization.name}</:col>
        <:col :let={{id, organization}}>
          <.button
            variant="primary"
            phx-click="view_members"
            phx-value-id={organization.id}
            id={"view-members-btn-#{id}"}
            class="flex items-center gap-2"
          >
            <.icon name="hero-users" /> View Members
          </.button>
        </:col>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_scope.user

    if connected?(socket) do
      Organizations.subscribe_organisations(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Organisations")
     |> stream(:organisations, list_user_organisations(current_user))}
  end

  @impl true
  def handle_info({type, %Organization{}}, socket)
      when type in [:created] do
    current_user = socket.assigns.current_scope.user
    {:noreply, stream(socket, :organisations, list_user_organisations(current_user), reset: true)}
  end

  @impl true
  def handle_event("view_members", %{"id" => org_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/organisations/members?org_id=#{org_id}")}
  end

  defp list_user_organisations(user) do
    Organizations.list_user_organisations(user)
  end

  defp can_create_org?(current_user), do: Abilities.can_create_organisation?(current_user)
end
