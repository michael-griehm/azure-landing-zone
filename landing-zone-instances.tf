terraform {
  required_providers {
    azuread = "~>2.16.0"
  }

  backend "azurerm" {
  }
}

module "azure_function_landing_zone" {
  source   = "./modules/landing-zone"
  app_name = "azure-function"
  github_organization_name = "michael-griehm"
  github_repo_name = "terraform-azure-function"
  remote_state_storage_ip_rules = ["74.83.138.51", "24.31.171.98"] 
}

