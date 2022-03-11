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
  tags                      = var.tags

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
  tags         = var.tags

  depends_on = [
    azurerm_key_vault_access_policy.current_deployer_acl
  ]
}

resource "azurerm_storage_container" "remote_state_container" {
  name                  = "${var.app_name}-remote-state-${local.loc}-${var.env}"
  storage_account_name  = azurerm_storage_account.remote_state.name
  container_access_type = "private"
}