defmodule OrganizationManagementSystem.Accounts.Abilities do
  @moduledoc """
  Provides authorization helpers for checking user abilities within the Accounts context.

  This module defines functions to determine if a given user (typically the current user in session)
  has permission to perform certain actions, such as creating roles or managing permissions.

  Example usage:

      iex> OrganizationManagementSystem.Accounts.Abilities.can_create_role?(current_user)
      true

  Extend this module with additional `can_*?/1` or `can_*?/2` functions as needed to support
  fine-grained access control throughout the application.
  """

  alias OrganizationManagementSystem.Accounts

  @approve_user_permission "review:stage:reviewed"
  @review_user_permission "review:stage:invited"
  @create_organisation_permission "org:create"


  def can_create_role?(current_user) do
    current_user.is_super_user?
  end

  def can_review_or_approve?(%{is_super_user?: true}) do
    true
  end

  def can_review_or_approve?(current_user) do
    can_approve_user?(current_user) or can_review_user?(current_user)
  end

  def can_create_organisation?(user) do
    user.is_super_user? or @create_organisation_permission in get_permissions_actions(user.id)
  end

  def can_approve_user?(user) do
    user.is_super_user? or
      @approve_user_permission in get_permissions_actions(user.id)
  end

  def can_review_user?(user) do
    user.is_super_user? or @review_user_permission in get_permissions_actions(user.id)
  end

  defp get_permissions_actions(user_id) do
    user_id |> Accounts.get_permissions_by_user_id() |> Enum.map(& &1.action)
  end
end
