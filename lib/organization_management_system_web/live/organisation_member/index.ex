defmodule OrganizationManagementSystemWeb.OrganizationMemberLive.Index do
  use OrganizationManagementSystemWeb, :live_view
  alias OrganizationManagementSystem.Accounts.Abilities
  alias OrganizationManagementSystem.Accounts
  alias OrganizationManagementSystem.Organizations
  alias OrganizationManagementSystem.Accounts
  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Organisations Memberships
        <:actions>
          <%= if can_add_member?(@current_scope.user, @org_id) do %>
            <.button variant="primary" navigate={~p"/organisations/members/new?#{[org_id: @org_id]}"}>
              <.icon name="hero-plus" /> Add Member
            </.button>
          <% end %>
        </:actions>
      </.header>

      <.table
        id="organisations"
        rows={@streams.organisation_members}
      >
        <:col :let={{_id, organization_member}} label="Name">{organization_member.name}</:col>
        <:col :let={{_id, organization_member}} label="Email">{organization_member.email}</:col>
        <:action :let={{_id, organization_member}}>
          <%= if member_has_no_role?(organization_member.id, @org_id) and can_grant_role?(@current_scope.user, @org_id) do %>
            <select
              id={"role-select-#{organization_member.id}"}
              phx-click="grant_role"
              phx-value-id={organization_member.id}
            >
              <option value="">Assign Role</option>
              <%= for {label, value} <- list_assignable_roles(organization_member.id, @org_id) do %>
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
  def mount(%{"org_id" => org_id}, _session, socket) do
    {:ok,
     socket
     |> assign(:org_id, org_id)
     |> assign(:page_title, "Listing Organisation Memberships")
     |> stream(:organisation_members, list_members(org_id))}
  end

  @impl true
  def handle_event("grant_role", params, socket) do
    org_id = socket.assigns.org_id
    user_id = params["id"]
    role_id = params["value"]

    case Accounts.assign_role_to_user(user_id, role_id, org_id) |> IO.inspect() do
      {:ok, _} ->
        {:noreply,
         socket
         |> stream(:organisation_members, list_members(org_id), reset: true)
         |> put_flash(:info, "Role assigned successfully")
         |> assign(:page_title, "Listing Organisation Memberships")
         |> push_navigate(to: ~p"/organisations/members?org_id=#{org_id}")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Member already has the role")}
    end
  end

  defp list_members(org_id) do
    Organizations.list_organization_members(org_id)
  end

  defp can_add_member?(current_user, org_id) do
    Abilities.can_add_org_member?(current_user, org_id)
  end

  defp list_assignable_roles(user_id, org_id) do
    user_id
    |> Accounts.get_organisation_roles_not_assigned_to_user(org_id)
    |> Enum.map(&{&1.name, &1.id})
  end

  defp member_has_no_role?(user_id, org_id) do
    !Organizations.user_has_role_in_org?(user_id, org_id)
  end

  def can_grant_role?(current_user, org_id) do
    Abilities.can_grant_role?(current_user, org_id)
  end
end
