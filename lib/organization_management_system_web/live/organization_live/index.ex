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

  defp list_organisations do
    Organizations.list_organisations()
  end
end
