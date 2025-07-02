variable "env_prefix" { type = string }
variable "environment" { type = string }
resource "azurerm_public_ip" "nat" {
  # count               = var.environment == "prod" ? 1 : 0 # <-- HERE
  name                = "${var.env_prefix}-nat-gw-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard" # Free-tier eligible (Standard has cost)
  zones               = ["1"]      # Required for Basic SKU
}

resource "azurerm_nat_gateway" "main" {
  # count                   = var.environment == "prod" ? 1 : 0 # <-- HERE
  name                    = "${var.env_prefix}-nat-gw"
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard" # No Basic SKU available for NAT GW
  idle_timeout_in_minutes = 4          # Minimum to reduce costs
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "backend" {
  subnet_id      = azurerm_subnet.backend.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}
