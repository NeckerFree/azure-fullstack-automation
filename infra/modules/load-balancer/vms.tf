# NICs for VMs
resource "azurerm_network_interface" "backend" {
  count               = 2 # Two instances for HA
  name                = "${var.env_prefix}-nic-backend-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.backend_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Connect NICs to LB backend pool
resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.backend[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

# Free-tier eligible VMs (B1ls)
resource "azurerm_linux_virtual_machine" "backend" {
  count               = 2
  name                = "${var.env_prefix}-vm-api-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1ls" # Free-tier eligible
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.backend[count.index].id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # Movie API deployment script
  custom_data = base64encode(templatefile("${path.module}/../../scripts/deploy_api.sh", {
    repo_url                   = "https://github.com/aljoveza/devops-rampup.git"
    mysql_flexible_server_fqdn = var.mysql_flexible_server_fqdn
  }))
}
