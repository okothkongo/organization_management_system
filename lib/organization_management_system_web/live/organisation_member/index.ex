defmodule OrganizationManagementSystemWeb.OrganizationMemberLive.Index do
  use OrganizationManagementSystemWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Organisations Memberships
        <:actions>
          <.button variant="primary" navigate={~p"/organisations/members/new?#{[org_id: @org_id]}"}>
            <.icon name="hero-plus" /> Add Member
          </.button>
        </:actions>
      </.header>

      <.table
        id="organisations"
        rows={@streams.organisation_members}
      >
        <:col :let={{_id, organization_member}} label="Name">{organization_member.name}</:col>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"org_id" => org_id}, _session, socket) do
    {:ok,
     socket
     |> assign(:org_id, org_id)
     |> assign(:page_title, "Listing Organisation Memberships")
     |> stream(:organisation_members, list_members(org_id))}
  end

  def list_members(org_id) do
    OrganizationManagementSystem.Organizations.list_organization_members(org_id)
  end
end
