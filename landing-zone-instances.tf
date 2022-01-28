terraform {
  required_providers {
    azuread = "~>2.16.0"
  }

  backend "azurerm" {
  }
}

module "azure_function_landing_zone" {
  source   = "./modules/landing-zone"
  app_name = "basic-func"
  github_organization_name = "michael-griehm"
  github_repo_name = "terraform-azure-function"
}

