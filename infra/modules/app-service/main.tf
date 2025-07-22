resource "azurerm_service_plan" "main" {
  name                = "${var.env_prefix}-${var.app_name}-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "F1"

}

resource "azurerm_linux_web_app" "main" {
  name                = "${var.env_prefix}-${var.app_name}-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    application_stack {
      node_version = "14-lts"
    }
    always_on = false # Must be false for Free Tier

    # Removed: use_32_bit_worker_process (now automatically 32-bit for Free Tier)
  }

  app_settings = {
    "API_BASE_URL"                        = "http://${var.lb_public_ip}/api"
    "NODE_ENV"                            = var.environment
    "WEBSITES_PORT"                       = "3000"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }

  identity {
    type = "SystemAssigned"
  }
}
