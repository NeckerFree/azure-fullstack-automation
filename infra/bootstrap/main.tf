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
  location             = var.location
}

resource "azurerm_resource_group" "state" {
  name     = "epam${local.name_prefix}-rg"
  location = local.location
  tags = {
    Workspace = local.normalized_workspace
  }
}

resource "azurerm_storage_account" "state" {
  name                     = "epam${local.name_prefix}sa"
  resource_group_name      = azurerm_resource_group.state.name
  location                 = azurerm_resource_group.state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

# MODERN STORAGE CONTAINER DEFINITION
resource "azurerm_storage_container" "state" {
  name               = "epamtfstate-${local.normalized_workspace}"
  storage_account_id = azurerm_storage_account.state.id # Critical change - uses ID instead of name
}

output "backend_config" {
  value = <<EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "${azurerm_resource_group.state.name}"
    storage_account_name = "${azurerm_storage_account.state.name}"
    container_name       = "${azurerm_storage_container.state.name}"
    key                  = "${local.normalized_workspace}.terraform.tfstate"
  }
}
EOF
}
