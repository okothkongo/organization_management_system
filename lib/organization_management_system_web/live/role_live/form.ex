defmodule OrganizationManagementSystemWeb.RoleLive.Form do
  use OrganizationManagementSystemWeb, :live_view

  alias OrganizationManagementSystem.Accounts
  alias OrganizationManagementSystem.Accounts.Role
  alias OrganizationManagementSystem.Organizations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage role records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="role-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input
          field={@form[:scope]}
          type="select"
          label="Scope"
          options={[{"Select Role Scope", ""}] ++ list_role_scope_options()}
        />
        <.input
          field={@form[:permission_id]}
          type="select"
          label="Permission"
          options={[{"Select Permision", ""}] ++ list_permission_options()}
        />
        <.input
          field={@form[:organisation_id]}
          type="select"
          label="Organisation"
          options={[{"Select Organisation", ""}] ++ list_organisation_options()}
        />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:system?]} type="checkbox" label="System?" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Role</.button>
          <.button navigate={return_path(@current_scope, @return_to, @role)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :new, _params) do
    role = %Role{created_by_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Role")
    |> assign(:role, role)
    |> assign(:form, to_form(Accounts.change_role(socket.assigns.current_scope, role)))
  end

  @impl true
  def handle_event("validate", %{"role" => role_params}, socket) do
    changeset =
      Accounts.change_role(socket.assigns.current_scope, socket.assigns.role, role_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"role" => role_params}, socket) do
    save_role(socket, socket.assigns.live_action, role_params)
  end

  defp save_role(socket, :new, role_params) do
    permission_id = role_params["permission_id"]

    case Accounts.create_role(socket.assigns.current_scope, role_params) do
      {:ok, role} ->
        Accounts.create_role_permission(%{role_id: role.id, permission_id: permission_id})

        {:noreply,
         socket
         |> put_flash(:info, "Role created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, role)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _role), do: ~p"/roles"
  defp return_path(_scope, "show", role), do: ~p"/roles/#{role}"

  defp list_permission_options do
    Accounts.list_permissions() |> Enum.map(&{&1.action, &1.id})
  end

  defp list_role_scope_options do
    Role |> Ecto.Enum.values(:scope) |> Enum.map(&{Phoenix.Naming.humanize(&1), &1})
  end

  defp list_organisation_options do
    Organizations.list_organisations() |> Enum.map(&{&1.name, &1.id})
  end
end
