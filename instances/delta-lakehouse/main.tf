terraform {
  required_providers {
    azuread = "~>2.16.0"
  }

  backend "azurerm" {
  }
}

module "delta_lakehouse_landing_zone" {
  source                    = "../../modules/landing-zone"
  app_name                  = "delta-lakehouse"
  github_organization_name  = "michael-griehm"
  github_repo_name          = "azure-delta-lakehouse"
  admin_user_principal_name = "mikeg@ish-star.com"
  env                       = "demo"
  github_bind_object        = "ref:refs/heads/main"

  tags = {
    environment = "demo"
    workload    = "delta-lakehouse"
  }

  deployer_group_assignments = [
    "c85ffe94-a507-46c4-b8f4-84c6cdd346e7" # contributor-networking-demo-eastus2
  ]
}
