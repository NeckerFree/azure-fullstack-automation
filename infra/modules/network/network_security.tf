resource "azurerm_network_security_group" "backend" {
  name                = "${var.env_prefix}-nsg-backend"
  resource_group_name = var.resource_group_name
  location            = var.location

  # SSH In
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # TCP Out
  security_rule {
    name                       = "allow-internal-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080" # Your backend app port
    source_address_prefix      = azurerm_subnet.backend.address_prefixes[0]
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "db" {
  name                = "${var.env_prefix}-nsg-db"
  resource_group_name = var.resource_group_name
  location            = var.location

  security_rule {
    name                       = "allow-backend-to-db"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["3306"] # MySQL default port
    source_address_prefix      = azurerm_subnet.backend.address_prefixes[0]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-all-other-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
