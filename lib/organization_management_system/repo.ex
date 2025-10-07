defmodule OrganizationManagementSystem.Repo do
  use Ecto.Repo,
    otp_app: :organization_management_system,
    adapter: Ecto.Adapters.Postgres
end
