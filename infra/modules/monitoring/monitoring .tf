resource "azurerm_storage_account" "store-acc" {
  name                     = "${var.env_prefix}storageacc"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_log_analytics_workspace" "shared" {
  name                = "${var.env_prefix}-logs-shared"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
}

# Free-tier compliant monitoring setup (using storage account)
resource "azurerm_monitor_diagnostic_setting" "lb_free" {
  name               = "lb-free-metrics"
  target_resource_id = var.lb_id

  # Load Balancer logs
  enabled_log {
    category = "LoadBalancerAlertEvent"
  }

  enabled_log {
    category = "LoadBalancerProbeHealthStatus"
  }

  # Metrics configuration (updated to non-deprecated format)
  enabled_metric {
    category = "AllMetrics"
  }

  storage_account_id = azurerm_storage_account.store-acc.id
}

# Enhanced monitoring (using Log Analytics workspace)
resource "azurerm_monitor_diagnostic_setting" "lb_full" {
  count              = var.enable_free_monitoring ? 0 : 1
  name               = "lb-full-monitoring"
  target_resource_id = var.lb_id

  enabled_log {
    category = "LoadBalancerAlertEvent"
  }

  enabled_log {
    category = "LoadBalancerProbeHealthStatus"
  }

  enabled_metric {
    category = "AllMetrics"
  }

  log_analytics_workspace_id = azurerm_log_analytics_workspace.shared.id
}

# Optional: Storage management policy for retention
resource "azurerm_storage_management_policy" "logs_retention" {
  storage_account_id = azurerm_storage_account.store-acc.id

  rule {
    name    = "30dayRetention"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 30
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
    }
  }
}
