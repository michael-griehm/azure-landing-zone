terraform {
  required_providers {
    azuread = "~>2.16.0"
  }

  backend "azurerm" {
  }
}

module "data_brick_demo_landing_zone" {
  source                    = "../../modules/landing-zone"
  app_name                  = "adls2"
  github_organization_name  = "michael-griehm"
  github_repo_name          = "azure-data-lake"
  admin_user_principal_name = "mikeg@ish-star.com"
  env                       = "demo"
  github_bind_object        = "ref:refs/heads/main"

  tags = {
    environment = "demo"
    workload    = "crypto-analytics"
  }

  deployer_group_assignments = [ 
    "b72189d3-d825-4400-8a5b-6877223ac6b4" # cryptoanalyticslake-stream-reader
    ]
}
