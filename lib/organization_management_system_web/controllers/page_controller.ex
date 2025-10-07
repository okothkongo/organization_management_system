defmodule OrganizationManagementSystemWeb.PageController do
  use OrganizationManagementSystemWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
