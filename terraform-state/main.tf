resource "azurerm_resource_group" "tfstate" {
  name     = "elio-tfstate-rg"
  location = var.location
}

resource "azurerm_storage_account" "tfstate" {
  name                            = "epamqatfstate"
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = var.location
  account_tier                    = "Premium" # Free-tier eligible
  account_replication_type        = "LRS"
  account_kind                    = "BlockBlobStorage"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = {
    environment = var.environment
    terraform   = "true"
    cost-center = "free-tier"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
