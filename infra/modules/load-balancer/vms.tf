# Obtener la clave pública ya sea del recurso generado o del archivo existente
locals {
  ssh_public_key = fileexists(pathexpand("~/.ssh/vm_ssh_key")) ? trimspace(file(pathexpand("~/.ssh/vm_ssh_key.pub"))) : tls_private_key.vm_ssh[0].public_key_openssh
}
# NICs for VMs
resource "azurerm_network_interface" "backend" {
  count               = 2 # Two instances for HA
  name                = "${var.env_prefix}-nic-backend-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name


  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.backend_subnet_id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.nodes[count.index].id
  }
}

# Connect NICs to LB backend pool
resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.backend[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

resource "azurerm_public_ip" "control" {
  name                = "${var.env_prefix}-pip-control"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static" # Add this for Standard SKU
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

resource "tls_private_key" "vm_ssh" {
  count     = fileexists(pathexpand("~/.ssh/vm_ssh_key")) ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "control" {
  name                  = "jumpbox"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_B1ls"
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.control.id]
  admin_ssh_key {
    username   = var.admin_username
    public_key = local.ssh_public_key
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
# Free-tier eligible VMs (B1ls)
resource "azurerm_linux_virtual_machine" "backend" {
  count               = 2
  name                = "${var.env_prefix}-vm-api-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1ls" # Free-tier eligible
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.backend[count.index].id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = local.ssh_public_key
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

# Generate ~/.ssh/vm_ssh_key from TLS private key
resource "local_file" "ssh_private_key" {
  count           = fileexists(pathexpand("~/.ssh/vm_ssh_key")) ? 0 : 1
  content         = tls_private_key.vm_ssh[0].private_key_openssh
  filename        = pathexpand("~/.ssh/vm_ssh_key")
  file_permission = "0600"
}

# Generate a Dynamic Ansible Inventory File
resource "local_file" "ansible_inventory" {
  content = templatefile("${abspath("${path.module}/../../../ansible/inventory.tmpl")}", {
    control = {
      name = azurerm_linux_virtual_machine.control.name
      ip   = azurerm_public_ip.control.ip_address
    }
    ssh_private_key_path = "${pathexpand("~/.ssh/vm_ssh_key")}"
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
    ssh_user = var.admin_username
  })
  filename = abspath("${path.module}/../../../ansible/inventory.ini")
}

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
