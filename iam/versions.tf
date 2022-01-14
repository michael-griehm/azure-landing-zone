terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.7"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-opentfstate-eastus2"
    storage_account_name = "saopentfstateastus2"
    container_name       = "rg-bootstrapper-iam-state"
    key                  = "terraform.tfstate"
  }
}

