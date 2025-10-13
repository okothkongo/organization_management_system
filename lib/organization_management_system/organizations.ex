defmodule OrganizationManagementSystem.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias OrganizationManagementSystem.Accounts.UserRole
  alias OrganizationManagementSystem.Accounts.Abilities
  alias OrganizationManagementSystem.Repo

  alias OrganizationManagementSystem.Organizations.Organization
  alias OrganizationManagementSystem.Accounts.Scope
  alias OrganizationManagementSystem.Accounts.Role
  alias OrganizationManagementSystem.Organizations.OrganizationUser
  alias OrganizationManagementSystem.Accounts.User

  @doc """
  Subscribes to scoped notifications about any organization changes.

  The broadcasted messages match the pattern:

    * {:created, %Organization{}}
    * {:updated, %Organization{}}
    * {:deleted, %Organization{}}

  """
  def subscribe_organisations(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(OrganizationManagementSystem.PubSub, "user:#{key}:organisations")
  end

  defp broadcast_organization(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(
      OrganizationManagementSystem.PubSub,
      "user:#{key}:organisations",
      message
    )
  end

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(scope, %{field: value})
      {:ok, %Organization{}}

      iex> create_organization(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_organization(%Scope{} = scope, attrs) do
    with {:ok, organization = %Organization{}} <-
           %Organization{}
           |> Organization.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_organization(scope, {:created, organization})
      {:ok, organization}
    end
  end

  def update_organization(%Scope{} = scope, %Organization{} = organization, attrs) do
    with {:ok, organization = %Organization{}} <-
           organization
           |> Organization.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_organization(scope, {:updated, organization})
      {:ok, organization}
    end
  end

  def get_organization!(id) do
    Repo.get!(Organization, id)
  end

  @doc """
  Returns the list of all organizations where user is member.
  For super users and user with permission to create organisation, it returns all organizations.

  ## Examples

      iex> list_user_organisations(user)
      [%Organization{}, ...]

  """
  def list_user_organisations(user) do
    Organization
    |> maybe_filter_by_user(user)
    |> Repo.all()
  end

  def list_organisations do
    Repo.all(Organization)
  end

  def change_organization(%Scope{} = scope, %Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs, scope)
  end

  @doc """
  Lists all users belonging to the given organization.

  ## Examples

      iex> list_users(organization)
      [%User{}, ...]

  """
  def list_organization_members(org_id) do
    query =
      from(u in User,
        join: ou in OrganizationUser,
        on: ou.user_id == u.id,
        where: ou.organisation_id == ^org_id
      )

    Repo.all(query)
  end

  def list_roles_by_organization(organisation_id) do
    query =
      from(r in Role,
        where: r.organisation_id == ^organisation_id
      )

    Repo.all(query)
  end

  def change_organization_user(
        %Scope{} = scope,
        %OrganizationUser{} = organization_user,
        attrs \\ %{}
      ) do
    OrganizationUser.changeset(organization_user, attrs, scope)
  end

  def create_organization_user(%Scope{} = scope, attrs) do
    %OrganizationUser{}
    |> OrganizationUser.changeset(attrs, scope)
    |> Repo.insert()
  end

  @doc """
  Checks if the user is a member of any organization.

  Returns true if the user is a member, otherwise false.
  """
  def member_of_org?(user_id, org_id) do
    query =
      from(u in User,
        join: ou in OrganizationUser,
        on: ou.user_id == u.id,
        where: u.id == ^user_id and ou.organisation_id == ^org_id
      )

    Repo.exists?(query)
  end

  @doc """
  Checks if a user has a role assigned in an organization.
  Returns true only if user is in org AND has a non-nil role_id.

  ## Examples
      iex> user_has_role_in_org?(1, 5)
      true

      iex> user_has_role_in_org?(2, 5)
      false
  """
  def user_has_role_in_org?(user_id, org_id) do
    query =
      from ur in UserRole,
        join: ou in OrganizationUser,
        on: ou.user_id == ur.user_id,
        where:
          ur.user_id == ^user_id and ou.organisation_id == ^org_id and
            not is_nil(ur.organisation_id)

    Repo.exists?(query)
  end

  def get_organization_user(user_id, org_id) do
    Repo.get_by(OrganizationUser, user_id: user_id, organisation_id: org_id)
  end

  def organization_member_has_organization_role?(user_id, org_id) do
    query =
      from(up in OrganizationUser,
        where: up.user_id == ^user_id and up.organisation_id == ^org_id and not is_nil(up.role_id)
      )

    Repo.exists?(query)
  end

  def delete_organization_member_role(user_id, org_id) do
    query =
      from ur in UserRole,
        join: ou in OrganizationUser,
        on: ou.user_id == ur.user_id,
        where:
          ur.user_id == ^user_id and ou.organisation_id == ^org_id and
            ur.organisation_id == ^org_id

    Repo.delete_all(query)
  end

  def delete_global_role(user_id) do
    query =
      from ur in UserRole,
        where: ur.user_id == ^user_id and is_nil(ur.organisation_id)

    Repo.delete_all(query)
  end

  defp maybe_filter_by_user(query, user) do
    if Abilities.has_priviledged_acces?(user) do
      query
    else
      from(o in query,
        join: ou in OrganizationUser,
        on: ou.organisation_id == o.id,
        where: ou.user_id == ^user.id
      )
    end
  end
end
