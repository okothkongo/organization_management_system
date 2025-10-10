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
  alias OrganizationManagementSystem.Organizations

  @approve_user_permission "review:stage:reviewed"
  @review_user_permission "review:stage:invited"
  @priviledged_permission "priviledged:access"
  @add_org_member "org:member:add"
  @grant_org_role "org:member:grant_role"

  def can_review_or_approve?(current_user) do
    can_approve_user?(current_user) or can_review_user?(current_user) or
      current_user.is_super_user?
  end

  def has_priviledged_acces?(user) do
    user.is_super_user? or Accounts.has_permission?(user.id, @priviledged_permission)
  end

  def can_approve_user?(user) do
    user.is_super_user? or
      Accounts.has_permission?(user.id, @approve_user_permission)
  end

  def can_review_user?(user) do
    user.is_super_user? or Accounts.has_permission?(user.id, @review_user_permission)
  end

  def can_add_org_member?(user, org_id) do
    is_member_allowed_to_add =
      Organizations.member_of_org?(user.id, org_id) and
        Accounts.has_permission?(user.id, @add_org_member)

    privileged = Accounts.has_permission?(user.id, @priviledged_permission)

    user.is_super_user? or is_member_allowed_to_add or privileged
  end

  def can_grant_role?(user, org_id) do
    can_grant_role =
      Organizations.member_of_org?(user.id, org_id) and
        Accounts.has_permission?(user.id, @grant_org_role)

    privileged = Accounts.has_permission?(user.id, @priviledged_permission)

    can_grant_role or user.is_super_user? or privileged
  end
end
