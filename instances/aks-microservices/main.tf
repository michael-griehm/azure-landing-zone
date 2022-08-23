terraform {
  required_providers {
    azuread = "~>2.16.0"
  }

  backend "azurerm" {
  }
}

module "networking_landing_zone" {
  source                    = "../../modules/landing-zone"
  app_name                  = "aks-microservices"
  github_organization_name  = "michael-griehm"
  github_repo_name          = "azure-aks-microservices"
  admin_user_principal_name = "mikeg@ish-star.com"
  env                       = "demo"
  github_bind_object        = "ref:refs/heads/main"

  tags = {
    environment = "demo"
    workload    = "aks-microservices"
  }

  deployer_group_assignments = []
}
