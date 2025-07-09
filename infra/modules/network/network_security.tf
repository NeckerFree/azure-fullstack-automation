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
    destination_address_prefix = "20.115.129.27/32" # Control node's public IP
  }

  # Rule 2: Allow control node to SSH to backend nodes
  # security_rule {
  #   name                       = "Allow-SSH-From-Control"
  #   priority                   = 110
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "22"
  #   source_address_prefix      = "20.115.129.27/32"
  #   destination_address_prefix = "10.0.2.0/24" # Backend subnet
  # }

  # Rule 3: Internal application communication
  # security_rule {
  #   name                       = "allow-internal-http"
  #   priority                   = 120
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "8080"        # Your backend app port
  #   source_address_prefix      = "10.0.2.0/24" # Backend subnet
  #   destination_address_prefix = "10.0.2.0/24" # Backend subnet
  # }

  # Explicit bastion-to-backend SSH rule
  # security_rule {
  #   name                       = "Allow-Bastion-SSH"
  #   priority                   = 900
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "22"
  #   source_address_prefix      = var.bastion_public_ip #"20.56.100.22/32" Your bastion's public IP
  #   destination_address_prefix = "*"
  # }

  # Outbound SSH rule (if needed)
  security_rule {
    name                       = "allow-outbound-to-vms"
    priority                   = 100
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
