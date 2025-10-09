defmodule OrganizationManagementSystemWeb.OrganizationLive.Index do
  use OrganizationManagementSystemWeb, :live_view

  alias OrganizationManagementSystem.Organizations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Organisations
        <:actions>
          <.button variant="primary" navigate={~p"/organisations/new"}>
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
    if connected?(socket) do
      Organizations.subscribe_organisations(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Organisations")
     |> stream(:organisations, list_organisations())}
  end

  @impl true
  def handle_info({type, %OrganizationManagementSystem.Organizations.Organization{}}, socket)
      when type in [:created] do
    {:noreply, stream(socket, :organisations, list_organisations(), reset: true)}
  end

  def handle_event("view_members", %{"id" => org_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/organisations/members?org_id=#{org_id}")}
  end

  defp list_organisations do
    Organizations.list_organisations()
  end
end
