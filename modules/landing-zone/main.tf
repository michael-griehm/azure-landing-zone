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