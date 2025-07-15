terraform {
  backend "azurerm" {
    resource_group_name  = "softsofttfstateqa-rg"
    storage_account_name = "softsofttfstateqasa"
    container_name       = "softtfstate-qa"
    key                  = "qa.terraform.tfstate"
  }
}
