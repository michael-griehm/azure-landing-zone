locals {
  loc      = lower(replace(var.location, " ", ""))
  rg_name  = "rg-${var.app_name}-${var.env}-${local.loc}"
}

data "azurerm_client_config" "current" {}

provider "azurerm" {
  features {}
}

provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
}

resource "azuread_group" "group" {
  display_name     = "deployer-${var.app_name}-${var.env}-${local.loc}"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true
}

resource "azurerm_role_assignment" "role-assignment" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Owner"
  principal_id         = azuread_group.group.object_id
}

resource "azuread_application" "registration" {
  display_name = "sp-${var.app_name}-${var.env}-${local.loc}"
  owners = [
    data.azurerm_client_config.current.object_id
  ]
}

resource "azuread_service_principal" "service_principal" {
  application_id = azuread_application.registration.application_id

}

resource "azuread_service_principal_password" "secret" {
  service_principal_id = azuread_service_principal.service_principal.id
}

data "azurerm_key_vault" "vault" {
  resource_group_name = "central-security"
  name                = "kv-central-security"
}

resource "azurerm_key_vault_secret" "stored_secret" {
  count        = 1
  name         = azuread_application.registration.display_name
  value        = azuread_service_principal_password.secret.value
  key_vault_id = data.azurerm_key_vault.vault.id
}

resource "azuread_group_member" "group_member" {
  group_object_id  = azuread_group.group.object_id
  member_object_id = azuread_service_principal.service_principal.object_id
}