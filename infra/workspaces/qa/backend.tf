terraform {
  backend "azurerm" {
    resource_group_name  = "epamepamtfstateqa-rg"
    storage_account_name = "epamepamtfstateqasa"
    container_name       = "epamtfstate-qa"
    key                  = "qa.terraform.tfstate"
  }
}
