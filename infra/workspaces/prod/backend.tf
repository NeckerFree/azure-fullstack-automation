terraform {
  backend "azurerm" {
    resource_group_name  = "softsofttfstateprod-rg"
    storage_account_name = "softsofttfstateprodsa"
    container_name       = "softtfstate-prod"
    key                  = "prod.terraform.tfstate"
  }
}
