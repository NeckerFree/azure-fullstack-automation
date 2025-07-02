terraform {
  backend "azurerm" {
    resource_group_name  = "elio-tfstate-rg"
    storage_account_name = "epamqatfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
