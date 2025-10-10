Here you go — clean, ready to copy and paste ✅

---

# 🏢 Organization Management System

This system is used to grant users different privileges within the platform based on their assigned **roles** and **permissions**.

---

## ⚙️ Dependencies

* **Elixir**: `~> 1.18.4`
* **Erlang/OTP**: `~> 28.0.4`
* **PostgreSQL**: `>= 15.0`

---

## 🚀 Starting the Project

* Run `mix setup` to:

  * Install dependencies
  * Migrate and seed the database
  * Build required assets

* Run `mix precommit` to ensure there are no linting or test violations.

* Start the server:

  ```bash
  mix phx.server
  ```

  Then visit [http://localhost:4000](http://localhost:4000) in your browser.

---

## 👥 Roles and Permissions

### 🛡️ Super Admin

* Invite new users into the system
* Create and view all roles
* Access all actions available to other roles

### 🏢 Privileged User

* Create and edit organizations
* Assign roles to other members, including organization-specific roles
* View all organizations

### 👀 Reviewer

* View users who are pending review
* Review and move users to the approval stage

### ✅ Approver

* View users who are pending approval
* Approve reviewed users

### 🔑 Role Grantor

* Assign roles to members within their organization

---

