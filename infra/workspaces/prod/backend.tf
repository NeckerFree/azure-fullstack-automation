terraform {
  backend "azurerm" {
    resource_group_name  = "epamepamtfstateprod-rg"
    storage_account_name = "epamepamtfstateprodsa"
    container_name       = "epamtfstate-prod"
    key                  = "prod.terraform.tfstate"
  }
}
