terraform {
  required_providers {
    azuread = "~>2.16.0"
  }

  backend "azurerm" {
  }
}

module "data_brick_demo_landing_zone" {
  source                    = "../../modules/landing-zone"
  app_name                  = "synapse"
  github_organization_name  = "michael-griehm"
  github_repo_name          = "azure-synapse"
  admin_user_principal_name = "mikeg@ish-star.com"
  env                       = "demo"
  github_bind_object        = "ref:refs/heads/main"
  location                  = "Central US"

  tags = {
    environment = "demo"
    workload    = "crypto-analytics"
  }

  deployer_group_assignments = [
    "8aba9f00-e6ca-4067-b11c-9e52bdfd5893" # reader-adls2-demo-eastus2
  ]
}
