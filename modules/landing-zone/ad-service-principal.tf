resource "azuread_application" "registration" {
  display_name = "${var.app_name}-${var.env}-${local.loc}-deployer"
  owners = [
    data.azurerm_client_config.current.object_id,
    data.azuread_user.admin.object_id
  ]

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # MS Graph API

    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All
      type = "Role"
    }

    resource_access {
      id   = "62a82d76-70ea-41e2-9197-370581804d09" # Group.ReadWrite.All
      type = "Role"
    }

    # resource_access {
    #   id = "18a4783c-866b-4cc7-a460-3d5e5662c884" # Application.ReadWrite.OwnedBy
    #   type = "Role"
    # }

    # resource_access {
    #   id = "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30" # Application.Read.All
    #   type = "Role"
    # }
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

  depends_on = [
    azuread_service_principal.service_principal
  ]
}

resource "azuread_group_member" "group_member" {
  group_object_id  = azuread_group.deployer_group.object_id
  member_object_id = azuread_service_principal.service_principal.object_id
}

resource "azurerm_key_vault_secret" "stored_secret" {
  name         = azuread_application.registration.display_name
  value        = azuread_service_principal_password.secret.value
  key_vault_id = azurerm_key_vault.vault.id
  tags         = var.tags

  depends_on = [
    azurerm_key_vault_access_policy.current_deployer_acl
  ]
}

resource "azuread_group_member" "deployer_group_memberships"{
  for_each = toset(var.deployer_group_assignments)
  group_object_id = each.value
  member_object_id = azuread_service_principal.service_principal.object_id
}