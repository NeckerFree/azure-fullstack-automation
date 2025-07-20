# =======================
# NICs for backend VMs
# =======================
resource "azurerm_network_interface" "backend" {
  count               = 2
  name                = "${var.env_prefix}-nic-backend-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.backend_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# =======================
# NIC backend pool association
# =======================
resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.backend[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

# =======================
# Control node NIC and IP
# =======================
resource "azurerm_public_ip" "control" {
  name                = "${var.env_prefix}-pip-control"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "control" {
  name                = "${var.env_prefix}-nic-control"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.backend_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.control.id
  }
}

# =======================
# JUMPBOX VM
# =======================
resource "azurerm_linux_virtual_machine" "control" {
  name                  = "jumpbox"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_B1ls"
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.control.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    disk_size_gb         = 30
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

# =======================
# BACKEND VMs
# =======================
resource "azurerm_linux_virtual_machine" "backend" {
  count               = 2
  name                = "${var.env_prefix}-vm-api-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1ls"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.backend[count.index].id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
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
}

# =======================
# Dynamic Ansible Inventory File
# =======================
resource "local_file" "ansible_inventory" {
  content = templatefile("${abspath("${path.module}/../../../ansible/inventory.tmpl")}", {
    control = {
      name = azurerm_linux_virtual_machine.control.name
      ip   = azurerm_public_ip.control.ip_address
    }
    ssh_private_key_path = pathexpand("~/.ssh/vm_ssh_key")
    nodes = [
      {
        name = azurerm_linux_virtual_machine.backend[0].name
        ip   = azurerm_linux_virtual_machine.backend[0].private_ip_address
      },
      {
        name = azurerm_linux_virtual_machine.backend[1].name
        ip   = azurerm_linux_virtual_machine.backend[1].private_ip_address
      }
    ]
    admin_user = var.admin_username
  })
  filename = abspath("${path.module}/../../../ansible/inventory.ini")
}

# =======================
# Fix Line Endings (Windows/Linux)
# =======================
resource "null_resource" "fix_inventory_line_endings" {
  depends_on = [local_file.ansible_inventory]

  provisioner "local-exec" {
    command = <<-EOT
      if command -v powershell >/dev/null 2>&1; then
        powershell -Command "(Get-Content -Raw '${local_file.ansible_inventory.filename}') -replace '\\r', '' | Set-Content -NoNewline '${local_file.ansible_inventory.filename}'"
      else
        sed -i 's/\r//' '${local_file.ansible_inventory.filename}'
      fi
    EOT
  }
}
