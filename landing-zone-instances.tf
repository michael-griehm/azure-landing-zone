terraform {
  required_providers {
    azuread = "~>2.16.0"
  }

  backend "azurerm" {
  }
}

module "azure_function_landing_zone" {
  source                    = "./modules/landing-zone"
  app_name                  = "basic-func"
  github_organization_name  = "michael-griehm"
  github_repo_name          = "terraform-azure-function"
  admin_user_principal_name = "mikeg@ish-star.com"
}


module "data_model_demo_landing_zone" {
  source                    = "./modules/landing-zone"
  app_name                  = "data-model"
  github_organization_name  = "michael-griehm"
  github_repo_name          = "azure-data-engineering-DP203"
  admin_user_principal_name = "mikeg@ish-star.com"
  env                       = "demo"
  github_bind_object        = "ref:refs/heads/main"
}

