resource "azuread_group" "deployer_group" {
  display_name     = "deployer-${var.app_name}-${var.env}-${local.loc}"
  security_enabled = true

  owners = [
    data.azurerm_client_config.current.object_id,
    data.azuread_user.admin.object_id
  ]
}

resource "azurerm_role_assignment" "deployer_group_role_assignment" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Owner"
  principal_id         = azuread_group.deployer_group.object_id
}

resource "azuread_group" "contributor_group" {
  display_name     = "contributor-${var.app_name}-${var.env}-${local.loc}"
  security_enabled = true

  owners = [
    data.azurerm_client_config.current.object_id,
    data.azuread_user.admin.object_id
  ]
}

resource "azurerm_role_assignment" "contributor_group_role_assignment" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.contributor_group.object_id
}

resource "azuread_group" "reader_group" {
  display_name     = "reader-${var.app_name}-${var.env}-${local.loc}"
  security_enabled = true

  owners = [
    data.azurerm_client_config.current.object_id,
    data.azuread_user.admin.object_id
  ]
}

resource "azurerm_role_assignment" "reader_group_role_assignment" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.reader_group.object_id
}