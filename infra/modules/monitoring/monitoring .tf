resource "azurerm_log_analytics_workspace" "shared" {
  name                = "${var.env_prefix}-logs-shared"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018" # Only SKU with Free Tier (first 5GB/month free)
  retention_in_days   = 30          # Free retention up to 30 days
}
# Free-tier compliant monitoring setup
resource "azurerm_monitor_diagnostic_setting" "lb_free" {
  count              = var.enable_free_monitoring ? 1 : 0
  name               = "lb-free-metrics"
  target_resource_id = var.lb_id

  # Minimal metrics collection (free)
  enabled_log {
    category = "LoadBalancerMetric"
  }

  # Required destination - uses the free Log Analytics workspace
  # First 5GB/month are free
  log_analytics_workspace_id = azurerm_log_analytics_workspace.shared.id

  # Explicitly disable other destinations
  storage_account_id             = null
  eventhub_authorization_rule_id = null
  partner_solution_id            = null
}

# Enhanced monitoring (when free tier is disabled)
resource "azurerm_monitor_diagnostic_setting" "lb_full" {
  count              = var.enable_free_monitoring ? 0 : 1
  name               = "lb-full-monitoring"
  target_resource_id = var.lb_id

  # Full metrics and logs
  enabled_log {
    category = "AllMetrics"
  }

  enabled_log {
    category = "AllLogs"
  }

  log_analytics_workspace_id = azurerm_log_analytics_workspace.shared.id
}
