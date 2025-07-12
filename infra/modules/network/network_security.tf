resource "azurerm_network_security_group" "main" {
  name                = "${var.env_prefix}-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location

  # Allow HTTP traffic to Load Balancer
  security_rule {
    name                       = "Allow-HTTP-8080-From-Internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow API traffic to backend VMs
  security_rule {
    name                       = "Allow-API-8080-From-LB"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = azurerm_subnet.backend.address_prefixes[0] # Only from internal subnet
    destination_address_prefix = "*"
  }

  # SSH access
  security_rule {
    name                       = "Allow-SSH-From-MyIP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    destination_address_prefix = "*"

    source_address_prefix = "*" # only for testing not production
    # source_address_prefixes = [
    #   var.allowed_ssh_ip,
    #   "4.227.0.0/17",
    #   "13.70.192.0/18",
    #   "13.104.220.0/25",
    #   "13.105.49.24/31",
    #   "23.100.64.0/21"
    # ] # correct way in production: my IP and some GH IPs from "actions" in https://api.github.com/meta
  }

  # Outbound rules
  security_rule {
    name                       = "Allow-All-Outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG to all network interfaces
resource "azurerm_network_interface_security_group_association" "jumpbox" {
  network_interface_id      = var.network_interface_control_id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_network_interface_security_group_association" "backend_0" {
  network_interface_id      = var.network_interface_backend_0_id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_network_interface_security_group_association" "backend_1" {
  network_interface_id      = var.network_interface_backend_1_id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Associate VMs to API backend pool
resource "azurerm_network_interface_backend_address_pool_association" "api_0" {
  network_interface_id    = var.network_interface_backend_0_id
  ip_configuration_name   = "internal"
  backend_address_pool_id = var.azurerm_lb_backend_address_pool_api_pool_id
}

resource "azurerm_network_interface_backend_address_pool_association" "api_1" {
  network_interface_id    = var.network_interface_backend_1_id
  ip_configuration_name   = "internal"
  backend_address_pool_id = var.azurerm_lb_backend_address_pool_api_pool_id
}
