terraform {
  required_providers {
    azuread = "~>2.16.0"
  }

  backend "azurerm" {
  }
}

module "data_brick_demo_landing_zone" {
  source                    = "../../modules/landing-zone"
  app_name                  = "dbx"
  github_organization_name  = "michael-griehm"
  github_repo_name          = "azure-databricks"
  admin_user_principal_name = "mikeg@ish-star.com"
  env                       = "demo"
  github_bind_object        = "ref:refs/heads/main"

  tags = {
    environment = "demo"
    workload    = "crypto-analytics"
  }

  deployer_group_assignments = [
    "5b303900-0e57-4a2f-9c74-32c5f698ae00" # contributor-adls2-demo-eastus2
  ]
}
