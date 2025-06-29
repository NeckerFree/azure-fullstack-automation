terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

locals {
  normalized_workspace = terraform.workspace == "default" ? "dev" : lower(terraform.workspace)
  name_prefix          = "epamtfstate${substr(local.normalized_workspace, 0, 4)}"
  env_suffix           = terraform.workspace == "prod" ? "prod" : "qa"
  location             = var.location
}

resource "azurerm_resource_group" "state" {
  name     = "epam${local.name_prefix}-rg"
  location = local.location
  tags = {
    Workspace = local.normalized_workspace
  }
}

module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
}

