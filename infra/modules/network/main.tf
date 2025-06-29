variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "env_suffix" {
  type = string
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.env_suffix}"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_subnet" "backend" {
  name                 = "backend-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "db-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

# resource "azurerm_network_security_group" "backend_nsg" {
#   name                = "nsg-backend-${var.env_suffix}"
#   location            = var.location
#   resource_group_name = var.resource_group_name

#   security_rule {
#     name                       = "AllowSSH"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "0.0.0.0/0"
#     destination_address_prefix = "*"
#     description                = "Allow SSH from anywhere"
#   }

#   security_rule {
#     name                       = "DenyAllInbound"
#     priority                   = 200
#     direction                  = "Inbound"
#     access                     = "Deny"
#     protocol                   = "*"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#     source_address_prefix      = "0.0.0.0/0"
#     destination_address_prefix = "*"
#     description                = "Deny all other inbound traffic"
#   }
# }

# resource "azurerm_subnet_network_security_group_association" "backend_assoc" {
#   subnet_id                 = azurerm_subnet.backend.id
#   network_security_group_id = azurerm_network_security_group.backend_nsg.id
# }
