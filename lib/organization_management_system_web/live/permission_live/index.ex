defmodule OrganizationManagementSystemWeb.PermissionLive.Index do
  use OrganizationManagementSystemWeb, :live_view
  alias OrganizationManagementSystem.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Permission
      </.header>

      <.table
        id="permissions"
        rows={@streams.permissions}
      >
        <:col :let={{_id, permission}} label="Action">{permission.action}</:col>
        <:col :let={{_id, permission}} label="Description">{permission.description}</:col>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Permission")
     |> stream(:permissions, list_permissions())}
  end

  defp list_permissions do
    Accounts.list_permissions()
  end
end
