defmodule OrganizationManagementSystemWeb.Router do
  use OrganizationManagementSystemWeb, :router

  import OrganizationManagementSystemWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {OrganizationManagementSystemWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OrganizationManagementSystemWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", OrganizationManagementSystemWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:organization_management_system, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: OrganizationManagementSystemWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", OrganizationManagementSystemWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{OrganizationManagementSystemWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
      get "/dashboard", PageController, :dashboard
      live "/organisations", OrganizationLive.Index, :index
      live "/organisations/new", OrganizationLive.Form, :new
      live "/organisations/members", OrganizationMemberLive.Index, :index

      live "/organisations/members/new", OrganizationMemberLive.Form, :new
    end

    post "/users/update-password", UserSessionController, :update_password

    live_session :require_authenticated_super_user,
      on_mount: [{OrganizationManagementSystemWeb.UserAuth, :require_authenticated_super_user}] do
      live "/roles", RoleLive.Index, :index
      live "/roles/new", RoleLive.Form, :new
      live "/roles/:id", RoleLive.Show, :show
      live "/users/register", UserLive.Registration, :new
    end

    live_session :require_authenticated_reviewer,
      on_mount: [{OrganizationManagementSystemWeb.UserAuth, :require_authenticated_reviewer}] do
      live "/users", UserLive.Index, :index
    end
  end

  scope "/", OrganizationManagementSystemWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{OrganizationManagementSystemWeb.UserAuth, :mount_current_scope}] do
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
