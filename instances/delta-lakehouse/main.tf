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
    "e2ed205f-16d0-4ebc-85c6-93ecbea6f79e" # reader-networking-demo-eastus2
  ]
}
