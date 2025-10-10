defmodule OrganizationManagementSystem.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias OrganizationManagementSystem.Organizations

  alias OrganizationManagementSystem.Accounts.UserPermission
  alias OrganizationManagementSystem.Accounts.RolePermission
  alias OrganizationManagementSystem.Accounts.Abilities
  alias OrganizationManagementSystem.Repo

  alias OrganizationManagementSystem.Accounts.{User, UserToken, UserNotifier}

  alias OrganizationManagementSystem.Accounts.Role
  alias OrganizationManagementSystem.Accounts.Scope
  alias OrganizationManagementSystem.Accounts.Permission
  alias OrganizationManagementSystem.Organizations.OrganizationUser
  alias Ecto.Multi

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.email_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  ## Settings

  @doc """
  Checks whether the user is in sudo mode.

  The user is in sudo mode when the last authentication was done no further
  than 20 minutes ago. The limit can be given as second argument in minutes.
  """
  def sudo_mode?(user, minutes \\ -20)

  def sudo_mode?(%User{authenticated_at: ts}, minutes) when is_struct(ts, DateTime) do
    DateTime.after?(ts, DateTime.utc_now() |> DateTime.add(minutes, :minute))
  end

  def sudo_mode?(_user, _minutes), do: false

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  See `OrganizationManagementSystem.Accounts.User.email_changeset/3` for a list of supported options.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}, opts \\ []) do
    User.email_changeset(user, attrs, opts)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    Repo.transact(fn ->
      with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
           %UserToken{sent_to: email} <- Repo.one(query),
           {:ok, user} <- Repo.update(User.email_changeset(user, %{email: email})),
           {_count, _result} <-
             Repo.delete_all(from(UserToken, where: [user_id: ^user.id, context: ^context])) do
        {:ok, user}
      else
        _ -> {:error, :transaction_aborted}
      end
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  See `OrganizationManagementSystem.Accounts.User.password_changeset/3` for a list of supported options.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}, opts \\ []) do
    User.password_changeset(user, attrs, opts)
  end

  @doc """
  Updates the user password.

  Returns a tuple with the updated user, as well as a list of expired tokens.

  ## Examples

      iex> update_user_password(user, %{password: ...})
      {:ok, {%User{}, [...]}}

      iex> update_user_password(user, %{password: "too short"})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> update_user_and_delete_all_tokens()
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.

  If the token is valid `{user, token_inserted_at}` is returned, otherwise `nil` is returned.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Gets the user with the given magic link token.
  """
  def get_user_by_magic_link_token(token) do
    with {:ok, query} <- UserToken.verify_magic_link_token_query(token),
         {user, _token} <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Logs the user in by magic link.

  There are three cases to consider:

  1. The user has already confirmed their email. They are logged in
     and the magic link is expired.

  2. The user has not confirmed their email and no password is set.
     In this case, the user gets confirmed, logged in, and all tokens -
     including session ones - are expired. In theory, no other tokens
     exist but we delete all of them for best security practices.

  3. The user has not confirmed their email but a password is set.
     This cannot happen in the default implementation but may be the
     source of security pitfalls. See the "Mixing magic link and password registration" section of
     `mix help phx.gen.auth`.
  """
  def login_user_by_magic_link(token) do
    {:ok, query} = UserToken.verify_magic_link_token_query(token)

    case Repo.one(query) do
      # Prevent session fixation attacks by disallowing magic links for unconfirmed users with password
      {%User{confirmed_at: nil, hashed_password: hash}, _token} when not is_nil(hash) ->
        raise """
        magic link log in is not allowed for unconfirmed users with a password set!

        This cannot happen with the default implementation, which indicates that you
        might have adapted the code to a different use case. Please make sure to read the
        "Mixing magic link and password registration" section of `mix help phx.gen.auth`.
        """

      {%User{confirmed_at: nil} = user, _token} ->
        user
        |> User.confirm_changeset()
        |> update_user_and_delete_all_tokens()

      {user, token} ->
        Repo.delete!(token)
        {:ok, {user, []}}

      nil ->
        {:error, :not_found}
    end
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm-email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Delivers the magic link login instructions to the given user.
  """
  def deliver_login_instructions(%User{} = user, magic_link_url_fun)
      when is_function(magic_link_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "login")
    Repo.insert!(user_token)
    UserNotifier.deliver_login_instructions(user, magic_link_url_fun.(encoded_token))
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(from(UserToken, where: [token: ^token, context: "session"]))
    :ok
  end

  ## Token helper

  defp update_user_and_delete_all_tokens(changeset) do
    Repo.transact(fn ->
      with {:ok, user} <- Repo.update(changeset) do
        tokens_to_expire = Repo.all_by(UserToken, user_id: user.id)

        Repo.delete_all(from(t in UserToken, where: t.id in ^Enum.map(tokens_to_expire, & &1.id)))

        {:ok, {user, tokens_to_expire}}
      end
    end)
  end

  @doc """
  Subscribes to scoped notifications about any role changes.

  The broadcasted messages match the pattern:

    * {:created, %Role{}}
    * {:updated, %Role{}}
    * {:deleted, %Role{}}

  """
  def subscribe_roles(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(OrganizationManagementSystem.PubSub, "user:#{key}:roles")
  end

  defp broadcast_role(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(OrganizationManagementSystem.PubSub, "user:#{key}:roles", message)
  end

  @doc """
  Returns the list of roles.

  ## Examples

      iex> list_roles()
      [%Role{}, ...]

  """
  def list_roles do
    Repo.all(Role)
  end

  @doc """
  Gets a single role.

  Raises `Ecto.NoResultsError` if the Role does not exist.

  ## Examples

      iex> get_role!(scope, 123)
      %Role{}

      iex> get_role!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_role!(id) do
    Repo.get!(Role, id)
  end

  @doc """
  Creates a role with associated permissions in a transaction.

  ## Parameters
    - scope: The current scope context
    - attrs: Role attributes including permission_id

  ## Examples
      iex> create_role(scope, %{name: "Admin",  1)
      {:ok, %Role{}}
  """

  def create_role(scope, role_attrs) do
    Multi.new()
    |> Multi.insert(:role, Role.changeset(%Role{}, role_attrs, scope))
    |> Multi.run(:role_permissions, fn _repo, %{role: role} ->
      permission_id = role_attrs["permission_id"] || role_attrs[:permission_id]
      create_role_permission(%{role_id: role.id, permission_id: permission_id})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        broadcast_role(scope, {:created, result.role})

        {:ok, result.role}

      {:error, :role, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking role changes.

  ## Examples

      iex> change_role(scope, role)
      %Ecto.Changeset{data: %Role{}}

  """
  def change_role(%Scope{} = scope, %Role{} = role, attrs \\ %{}) do
    Role.changeset(role, attrs, scope)
  end

  @doc """
  Returns the list of all permissions.

  ## Examples

      iex> list_permissions()
      [%Permission{}, ...]

  """
  @spec list_permissions() :: [Permission.t()]
  def list_permissions do
    Repo.all(Permission)
  end

  def create_role_permission(attrs) do
    %RolePermission{}
    |> RolePermission.changeset(attrs)
    |> Repo.insert()
  end

  def list_users(%{user: %{is_super_user?: true}} = _scope) do
    Repo.all(User)
  end

  def list_users(%{user: user}) do
    cond do
      user.is_super_user? ->
        Repo.all(User)

      Abilities.can_review_user?(user) ->
        Repo.all_by(User, status: :invited)

      Abilities.can_approve_user?(user) ->
        Repo.all_by(User, status: :reviewed)

      true ->
        []
    end
  end

  @doc """
  Returns the list of permissions for a given user_id.

  This function joins the user_permissions and permissions tables
  to find all permissions assigned to the user.

  ## Examples

      iex> get_permissions_by_user_id(1)
      [%Permission{}, ...]
  """
  @spec get_permissions_by_user_id(integer()) :: [Permission.t()]
  def get_permissions_by_user_id(user_id) do
    query =
      from p in Permission,
        join: up in UserPermission,
        on: up.permission_id == p.id,
        where: up.user_id == ^user_id,
        select: p

    Repo.all(query)
  end

  def get_permission_by_action!(action) do
    Repo.get_by!(Permission, action: action)
  end

  def create_user_permission(attrs, scope) do
    %UserPermission{}
    |> UserPermission.changeset(attrs, scope)
    |> Repo.insert()
  end

  @doc """
  Returns the list of permissions for a given role_id.

  ## Examples

      iex> get_permissions_by_role_id(role_id)
      [%Permission{}, ...]

  """
  @spec get_permissions_by_role_id(integer()) :: [Permission.t()]
  def get_permissions_by_role_id(role_id) do
    query =
      from p in Permission,
        join: rp in RolePermission,
        on: rp.permission_id == p.id,
        where: rp.role_id == ^role_id,
        select: p

    Repo.one(query)
  end

  def list_users do
    Repo.all(User)
  end

  @doc """
  Assigns a user to a role within an organization.
  Returns {:ok, org_user} if successful or user already has the role.
  """
  def assign_member_to_role(user_id, role_id, org_id, scope) do
    case Organizations.get_organization_user(user_id, org_id) do
      %OrganizationUser{role_id: ^role_id} ->
        {:error, :user_already_has_role}

      org_user ->
        org_user
        |> OrganizationUser.changeset(%{role_id: role_id}, scope)
        |> Repo.update()
    end
  end

  @doc """
  Gets all roles that a user has NOT been assigned in a specific organization.

  ## Parameters
    - user_id: The ID of the user
    - org_id: The ID of the organization

  ## Examples
      iex> get_unassigned_roles_for_user(1, 5)
      [%Role{}, ...]
  """
  def get_unassigned_roles_for_user(user_id, org_id) do
    # Subquery to get the role_id the user currently has in this org
    assigned_role_subquery =
      from ou in OrganizationUser,
        where: ou.user_id == ^user_id and ou.organisation_id == ^org_id,
        select: ou.role_id

    # Get all roles for this organization that are NOT assigned to the user
    query =
      from r in Role,
        where: r.organisation_id == ^org_id or r.scope == :all,
        where: r.id not in subquery(assigned_role_subquery),
        order_by: [asc: r.name],
        preload: [:permissions]

    Repo.all(query)
  end
end
