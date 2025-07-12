resource "azurerm_network_security_group" "jumpbox_nsg" {
  name                = "${var.env_prefix}-jumpbox_nsg"
  resource_group_name = var.resource_group_name
  location            = var.location
  security_rule {
    name                       = "Allow-HTTP-8080-From-Internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*" # Or use "Internet"
    destination_address_prefix = "*" # Or specific subnet
  }
  # Rule 1: Allow your IP to SSH to control node
  security_rule {
    name                   = "Allow-SSH-From-MyIP"
    priority               = 110
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "22"
    source_address_prefix  = "*" # only for testing not production
    # source_address_prefixes = [
    #   var.allowed_ssh_ip,
    #   "4.227.0.0/17",
    #   "13.70.192.0/18",
    #   "13.104.220.0/25",
    #   "13.105.49.24/31",
    #   "23.100.64.0/21"
    # ] # correct way in production: my IP and some GH IPs from "actions" in https://api.github.com/meta
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-mysql-out"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # Outbound SSH rule (if needed)
  security_rule {
    name                       = "allow-outbound-to-vms"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_subnet.backend.address_prefixes[0]
  }
}

# Asocia el NSG al Jumpbox
resource "azurerm_network_interface_security_group_association" "jumpbox" {
  network_interface_id      = var.network_interface_control_id
  network_security_group_id = azurerm_network_security_group.jumpbox_nsg.id
}

resource "azurerm_network_interface_security_group_association" "backend_nic_0" {
  network_interface_id      = var.network_interface_backend_0_id
  network_security_group_id = azurerm_network_security_group.jumpbox_nsg.id
}

resource "azurerm_network_interface_security_group_association" "backend_nic_1" {
  network_interface_id      = var.network_interface_backend_1_id
  network_security_group_id = azurerm_network_security_group.jumpbox_nsg.id
}

resource "azurerm_network_security_rule" "api" {
  name                        = "AllowAPI3000"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.jumpbox_nsg.name
}
