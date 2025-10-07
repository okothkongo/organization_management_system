defmodule OrganizationManagementSystem.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OrganizationManagementSystemWeb.Telemetry,
      OrganizationManagementSystem.Repo,
      {DNSCluster, query: Application.get_env(:organization_management_system, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: OrganizationManagementSystem.PubSub},
      # Start a worker by calling: OrganizationManagementSystem.Worker.start_link(arg)
      # {OrganizationManagementSystem.Worker, arg},
      # Start to serve requests, typically the last entry
      OrganizationManagementSystemWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OrganizationManagementSystem.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OrganizationManagementSystemWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
