data "azurerm_client_config" "current" {}

data "azurerm_subscription" "primary" {}

provider "azurerm" {
  features {}
}

provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

resource "azuread_group" "group" {
  display_name     = "${var.app_name}-deployer"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true
}

resource "azurerm_role_assignment" "role-assignment" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Owner"
  principal_id         = azuread_group.group.object_id
}

resource "azuread_application" "registration" {
  display_name = "${var.app_name}-deployer"
  owners = [
    data.azurerm_client_config.current.object_id
  ]
}

resource "azuread_service_principal" "service_principal" {
  application_id = azuread_application.registration.application_id

  depends_on = [
    azuread_application.registration
  ]
}

resource "azuread_service_principal_password" "secret" {
  service_principal_id = azuread_service_principal.service_principal.id

  depends_on = [
    azuread_service_principal.service_principal
  ]
}

data "azurerm_resource_group" "vault_rg" {
  name = "central-security"
}

resource "azurerm_key_vault" "vault" {
  resource_group_name         = data.azurerm_resource_group.vault_rg.name
  location                    = data.azurerm_resource_group.vault_rg.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  name                        = length("kv-${azuread_application.registration.display_name}") > 24 ? substr("kv-${azuread_application.registration.display_name}", 0, 24) : "kv-${azuread_application.registration.display_name}"
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
}

resource "azurerm_key_vault_access_policy" "sp-acl" {
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
  count        = 1
  name         = azuread_application.registration.display_name
  value        = azuread_service_principal_password.secret.value
  key_vault_id = azurerm_key_vault.vault.id

  depends_on = [
    azurerm_key_vault_access_policy.current_deployer_acl
  ]
}

resource "azuread_group_member" "group_member" {
  group_object_id  = azuread_group.group.object_id
  member_object_id = azuread_service_principal.service_principal.object_id

  depends_on = [
    azuread_group.group,
    azuread_service_principal.service_principal
  ]
}

data "azurerm_resource_group" "remote_state_rg" {
  name = "rg-opentfstate-eastus2"
}

data "azurerm_storage_account" "remote_state" {
  resource_group_name = data.azurerm_resource_group.remote_state_rg.name
  name = "saopentfstateastus2"
}

resource "azurerm_key_vault_secret" "stored_remote_state_access" {
  count        = 1
  name         = "${data.azurerm_storage_account.remote_state.name}-access-key"
  value        = data.azurerm_storage_account.remote_state.primary_access_key
  key_vault_id = azurerm_key_vault.vault.id

  depends_on = [
    azurerm_key_vault_access_policy.current_deployer_acl
  ]
}
