defmodule OrganizationManagementSystemWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use OrganizationManagementSystemWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  @doc """
  Renders the authenticated sidebar navigation for logged-in users.

  This sidebar is styled to match the project's theme and uses Tailwind CSS classes.
  It adapts to the current user's role (admin or not) and displays relevant navigation links.
  """
  attr :current_scope, :map, required: true

  def authenticated_navbar(assigns) do
    ~H"""
    <!-- Static sidebar for desktop -->
    <aside class="hidden lg:fixed lg:inset-y-0 lg:flex lg:w-64 lg:flex-col z-30">
      <div class="flex grow flex-col overflow-y-auto bg-primary-900 pt-5 border-r border-base-300 shadow-lg">
        <nav
          aria-label="Sidebar"
          class="mt-6 flex flex-1 flex-col divide-y divide-primary-800 overflow-y-auto"
        >
          <div class="space-y-1 px-2">
            <%= if @current_scope && Map.get(@current_scope.user, :is_super_user?, false) do %>
              <.link
                navigate={~p"/dashboard"}
                aria-current="page"
                class={[
                  "group flex items-center rounded-md px-2 py-2 text-sm font-medium",
                  "bg-primary-800 text-white"
                ]}
              >
                <.icon name="hero-home" class="mr-4 size-6 shrink-0 text-primary-200" /> Dashboard
              </.link>

              <.link
                navigate={~p"/roles"}
                class="group flex items-center rounded-md px-2 py-2 text-sm font-medium text-primary-100 hover:bg-primary-700 hover:text-white"
              >
                <.icon name="hero-users" class="mr-4 size-6 shrink-0 text-primary-200" /> Roles
              </.link>
              <.link
                navigate={~p"/users"}
                class="group flex items-center rounded-md px-2 py-2 text-sm font-medium text-primary-100 hover:bg-primary-700 hover:text-white"
              >
                <.icon name="hero-user-plus" class="mr-4 size-6 shrink-0 text-primary-200" /> Users
              </.link>
            <% else %>
              <.link
                navigate={~p"/dashboard"}
                aria-current="page"
                class={[
                  "group flex items-center rounded-md px-2 py-2 text-sm font-medium",
                  "bg-primary-800 text-white"
                ]}
              >
                <.icon name="hero-home" class="mr-4 size-6 shrink-0 text-primary-200" /> Dashboard
              </.link>
            <% end %>
            <.link
              navigate={~p"/users/settings"}
              class="group flex items-center rounded-md px-2 py-2 text-sm font-medium text-primary-100 hover:bg-primary-700 hover:text-white"
            >
              <.icon name="hero-cog-6-tooth" class="mr-4 size-6 shrink-0 text-primary-200" />Settings
            </.link>
            <.link
              href={~p"/users/log-out"}
              method="delete"
              class="group flex items-center rounded-md px-2 py-2 text-sm font-medium text-primary-100 hover:bg-primary-700 hover:text-white"
            >
              <.icon
                name="hero-arrow-right-on-rectangle"
                class="mr-4 size-6 shrink-0 text-primary-200"
              />Logout
            </.link>
          </div>
        </nav>
      </div>
    </aside>
    """
  end
end
