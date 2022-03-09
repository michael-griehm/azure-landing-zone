locals {
  loc     = lower(replace(var.location, " ", ""))
  a_name  = replace(var.app_name, "-", "")
  rg_name = "${var.app_name}-${var.env}-${local.loc}"
}

data "azurerm_client_config" "current" {}

provider "azurerm" {
  features {}
}

provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

data "azuread_user" "admin" {
  user_principal_name = var.admin_user_principal_name
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
}

resource "azuread_group" "group" {
  display_name = "deployer-${var.app_name}-${var.env}-${local.loc}"
  owners = [
    data.azurerm_client_config.current.object_id,
    data.azuread_user.admin.object_id
  ]
  security_enabled = true
}

resource "azurerm_role_assignment" "role-assignment" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Owner"
  principal_id         = azuread_group.group.object_id
}

resource "azuread_application" "registration" {
  display_name = "${var.app_name}-${var.env}-${local.loc}-deployer"
  owners = [
    data.azurerm_client_config.current.object_id,
    data.azuread_user.admin.object_id
  ]

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"  # MS Graph app id.

    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All id.
      type = "Role"
    }
  }
}

resource "azuread_service_principal" "service_principal" {
  application_id = azuread_application.registration.application_id

}

resource "azuread_service_principal_password" "secret" {
  service_principal_id = azuread_service_principal.service_principal.id
}

resource "azuread_application_federated_identity_credential" "federation" {
  application_object_id = azuread_application.registration.object_id
  display_name          = "github-action-deployer-federation"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github_organization_name}/${var.github_repo_name}:${var.github_bind_object}"
}

resource "azuread_group_member" "group_member" {
  group_object_id  = azuread_group.group.object_id
  member_object_id = azuread_service_principal.service_principal.object_id
}

resource "azurerm_key_vault" "vault" {
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  name                        = "deploy${length(local.a_name) > 16 ? substr(local.a_name, 0, 16) : local.a_name}${substr(local.loc, 0, 1)}${substr(var.env, 0, 1)}"
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
}

resource "azurerm_key_vault_access_policy" "sp_acl" {
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_service_principal.service_principal.object_id

  secret_permissions = [
    "Get",
  ]

  depends_on = [
    azurerm_key_vault.vault
  ]
}

resource "azurerm_key_vault_access_policy" "admin_acl" {
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_user.admin.object_id

  secret_permissions = [
    "Get",
    "List"
  ]

  depends_on = [
    azurerm_key_vault.vault
  ]
}

resource "azurerm_key_vault_access_policy" "current_deployer_acl" {
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]

  depends_on = [
    azurerm_key_vault.vault
  ]
}

resource "azurerm_key_vault_secret" "stored_secret" {
  name         = azuread_application.registration.display_name
  value        = azuread_service_principal_password.secret.value
  key_vault_id = azurerm_key_vault.vault.id

  depends_on = [
    azurerm_key_vault_access_policy.current_deployer_acl
  ]
}

resource "azurerm_storage_account" "remote_state" {
  name                      = "tf${length(local.a_name) > 20 ? substr(local.a_name, 0, 20) : local.a_name}${substr(local.loc, 0, 1)}${substr(var.env, 0, 1)}"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  access_tier               = "Hot"
  allow_blob_public_access  = false

  identity {
    type = "SystemAssigned"
  }

  network_rules {
    default_action = var.remote_state_storage_default_action
    ip_rules       = var.remote_state_storage_ip_rules
  }
}

resource "azurerm_key_vault_secret" "stored_remote_state_access" {
  name         = "${azurerm_storage_account.remote_state.name}-access-key"
  value        = azurerm_storage_account.remote_state.primary_access_key
  key_vault_id = azurerm_key_vault.vault.id

  depends_on = [
    azurerm_key_vault_access_policy.current_deployer_acl
  ]
}

resource "azurerm_storage_container" "remote_state_container" {
  name                  = "${var.app_name}-remote-state-${local.loc}-${var.env}"
  storage_account_name  = azurerm_storage_account.remote_state.name
  container_access_type = "private"
}