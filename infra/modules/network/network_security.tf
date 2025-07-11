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
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-mysql-out"
    priority                   = 110
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
    priority                   = 120
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
