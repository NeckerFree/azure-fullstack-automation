resource "azurerm_network_security_group" "jumpbox_nsg" {
  name                = "${var.env_prefix}-jumpbox_nsg"
  resource_group_name = var.resource_group_name
  location            = var.location

  # Rule 1: Allow your IP to SSH to control node
  security_rule {
    name                       = "Allow-SSH-From-MyIP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_ip
    destination_address_prefix = var.network_interface_control_private_ip
  }

  # Outbound SSH rule (if needed)
  security_rule {
    name                       = "allow-outbound-to-vms"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_subnet.backend.address_prefixes[0]
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

# Asocia el NSG al Jumpbox
resource "azurerm_network_interface_security_group_association" "jumpbox" {
  network_interface_id      = var.network_interface_control_id
  network_security_group_id = azurerm_network_security_group.jumpbox_nsg.id
}
