terraform {
  backend "azurerm" {
  }
}

module "github_runners" {
  source   = "./modules/rg-bootstrap"
  app_name = "githubrunners"
}