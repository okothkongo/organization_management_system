defmodule OrganizationManagementSystemWeb.OrganizationMemberLive.Form do
  use OrganizationManagementSystemWeb, :live_view

  alias OrganizationManagementSystem.Organizations
  alias OrganizationManagementSystem.Organizations.OrganizationUser

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage memmbers records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="member-form" phx-change="validate" phx-submit="save">
        <div :if={@form.errors != []} class="alert alert-error mb-4">
          <.icon name="hero-exclamation-triangle" class="size-6 shrink-0" />
          <div>
            <h3 class="font-bold">Please fix the following errors:</h3>
            <ul class="list-disc list-inside">
              <li :for={{_field, error} <- @form.errors}>{translate_error(error)}</li>
            </ul>
          </div>
        </div>

        <.input
          field={@form[:user_id]}
          type="select"
          label="User Email"
          options={[{"Select User Email", ""}] ++ list_user_options()}
        />

        <.input
          field={@form[:role_id]}
          type="select"
          label="Assign Role"
          options={[{"Select Role", ""}] ++ list_organization_roles(@org_id)}
        />

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save member</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    org_id = params["org_id"]

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:org_id, org_id)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to(_), do: "index"

  defp apply_action(socket, :new, _params) do
    organization_user = %OrganizationUser{
      invited_by_id: socket.assigns.current_scope.user.id,
      organisation_id: socket.assigns.org_id
    }

    socket
    |> assign(:page_title, "New OMembership")
    |> assign(:organization_user, organization_user)
    |> assign(
      :form,
      to_form(
        Organizations.change_organization_user(socket.assigns.current_scope, organization_user),
        action: :insert
      )
    )
  end

  @impl true
  def handle_event("validate", %{"organization_user" => organization_user_params}, socket) do
    organization_user_params =
      Map.put_new(organization_user_params, "organisation_id", socket.assigns.org_id)

    changeset =
      Organizations.change_organization_user(
        socket.assigns.current_scope,
        socket.assigns.organization_user,
        organization_user_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"organization_user" => organization_user_params}, socket) do
    organization_user_params =
      Map.put_new(organization_user_params, "organisation_id", socket.assigns.org_id)

    save_organization(socket, socket.assigns.live_action, organization_user_params)
  end

  defp save_organization(socket, :new, member_params) do
    case Organizations.create_organization_user(socket.assigns.current_scope, member_params) do
      {:ok, organization_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "member  successfully invited")
         |> push_navigate(
           to:
             return_path(
               socket.assigns.current_scope,
               socket.assigns.return_to,
               organization_user
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", organization_user),
    do: ~p"/organisations/members?org_id=#{organization_user.organisation_id}"

  defp list_user_options do
    OrganizationManagementSystem.Accounts.list_users()
    |> Enum.map(&{&1.email, &1.id})
  end

  defp list_organization_roles(org_id) do
    org_id
    |> OrganizationManagementSystem.Organizations.list_roles_by_organization()
    |> Enum.map(&{&1.name, &1.id})
  end
end
