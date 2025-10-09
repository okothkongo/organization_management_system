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

  def can_create_role?(current_user) do
    current_user.is_super_user?
  end

  def can_review_or_approve?(%{is_super_user?: true}) do
    true
  end

  def can_review_or_approve?(current_user) do
    current_user.id
    |> Accounts.get_global_roles_by_user_id_and_role_names(["user_reviewer", "user_approver"])
    |> Enum.empty?()
    |> Kernel.!()
  end

  def can_create_organisation?(%{is_super_user?: true}), do: true

  def can_create_organisation?(current_user) do
    current_user.id
    |> Accounts.get_global_roles_by_user_id_and_role_names(["organisation create"])
    |> Enum.empty?()
    |> Kernel.!()
  end
end
