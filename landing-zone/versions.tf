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
  }
}

