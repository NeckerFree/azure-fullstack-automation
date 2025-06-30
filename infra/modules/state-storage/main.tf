resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate"
  location = var.location
}
resource "azurerm_storage_account" "tfstate" {
  name                            = "${var.normalized_workspace}tfstate"
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = var.location
  account_tier                    = "Standard" # No free tier for storage accounts
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2" # Most cost-effective
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  # Critical for cost control
  blob_properties {
    delete_retention_policy {
      days = 7 # Minimum retention
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = {
    environment = "staging"
    cost-center = "free-tier"
  }
}
