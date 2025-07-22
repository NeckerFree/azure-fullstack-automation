resource "azurerm_public_ip" "lb" {
  name                = "${var.env_prefix}-lb-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "main" {
  name                = "${var.env_prefix}-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LBFrontend"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

# Default backend pool for other services
resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "BackendPool"
}

# Dedicated backend pool for Movie API
resource "azurerm_lb_backend_address_pool" "api_pool" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "MovieAPIBackendPool"
}

# HTTP probe for default services
resource "azurerm_lb_probe" "http" {
  loadbalancer_id     = azurerm_lb.main.id
  name                = "HTTP-Probe"
  port                = var.lb_api_port
  protocol            = "Http"
  request_path        = "/"
  interval_in_seconds = 15
}

# Dedicated probe for Movie API
resource "azurerm_lb_probe" "api" {
  loadbalancer_id     = azurerm_lb.main.id
  name                = "API-Probe"
  port                = var.lb_api_port
  protocol            = "Http"
  request_path        = "/health"
  interval_in_seconds = 15
}

# Movie API specific rule
resource "azurerm_lb_rule" "movie_api" {
  name                           = "MovieAPIRule"
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = "Tcp"
  frontend_port                  = var.lb_api_port
  backend_port                   = var.lb_api_port
  frontend_ip_configuration_name = "LBFrontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.api_pool.id]
  probe_id                       = azurerm_lb_probe.api.id
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 30
}

