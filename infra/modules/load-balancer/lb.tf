
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
  sku                 = "Standard" # Free-tier eligible

  frontend_ip_configuration {
    name                 = "LBFrontend"
    public_ip_address_id = azurerm_public_ip.lb.id
    # private_ip_address_allocation = "Dynamic"
    # subnet_id                     = azurerm_subnet.private.id
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "BackendPool"
}

resource "azurerm_lb_probe" "http" {
  loadbalancer_id     = azurerm_lb.main.id
  name                = "HTTP-Probe"
  port                = 8080 # Movie API port
  protocol            = "Http"
  request_path        = "/health"
  interval_in_seconds = 15
}

# resource "azurerm_lb_rule" "http" {
#   loadbalancer_id                = azurerm_lb.main.id
#   name                           = "HTTP"
#   protocol                       = "Tcp"
#   frontend_port                  = 80
#   backend_port                   = 8080 # App listens on 8080
#   frontend_ip_configuration_name = "LBFrontend"
#   backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
#   probe_id                       = azurerm_lb_probe.http.id
# }

# 2. Create a distinct rule with unique parameters
resource "azurerm_lb_rule" "movie_api" {
  name                           = "MovieAPIRule"
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = "Tcp"
  frontend_port                  = 8080 # Public port
  backend_port                   = 3000 # Different from other rules
  frontend_ip_configuration_name = azurerm_lb.main.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id] # Unique pool
  probe_id                       = azurerm_lb_probe.http.id
  enable_floating_ip             = true # Different from other rules
  idle_timeout_in_minutes        = 30   # Extended timeout for APIs
}
