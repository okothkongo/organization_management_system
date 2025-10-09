defmodule OrganizationManagementSystem.OrganizationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `OrganizationManagementSystem.Organizations` context.
  """

  @doc """
  Generate a organization.
  """
  def organization_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name"
      })

    {:ok, organization} =
      OrganizationManagementSystem.Organizations.create_organization(scope, attrs)

    organization
  end
end
