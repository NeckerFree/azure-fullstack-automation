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

resource "azurerm_linux_virtual_machine" "control" {
  name                  = "jumpbox"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_B1ls"
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.control.id]
  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.vm_ssh.public_key_openssh
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
    public_key = tls_private_key.vm_ssh.public_key_openssh
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

# Optional: generate a TLS private key (only if needed)
resource "tls_private_key" "vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create ~/.ssh if not exists
resource "null_resource" "ensure_ssh_folder" {
  provisioner "local-exec" {
    command = "powershell -Command \"New-Item -ItemType Directory -Force -Path $HOME\\.ssh\""
  }
}

resource "local_file" "temp_ssh_key" {
  content         = tls_private_key.vm_ssh.private_key_openssh
  filename        = "${path.module}/temp_vm_ssh_key"
  file_permission = "0600"
}

# Generate SSH private key file *only if it doesn't exist*
resource "null_resource" "write_ssh_key_once" {
  provisioner "local-exec" {
    command = <<EOT
powershell.exe -Command "
  \$targetPath = Join-Path \$env:USERPROFILE '.ssh\\vm_ssh_key';
  if (!(Test-Path -Path \$targetPath)) {
    Write-Host '📁 Target path does not exist. Copying SSH key...';
    Copy-Item -Path 'modules/load-balancer/temp_vm_ssh_key' -Destination \$targetPath;
    icacls \$targetPath /inheritance:r /grant:r `"\$env:USERNAME`:F`";
    Write-Host '✅ SSH key copied to: ' \$targetPath;
  } else {
    Write-Host 'ℹ️ SSH key already exists at: ' \$targetPath;
  }
"
EOT
  }
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
      powershell -Command "(Get-Content -Raw '${local_file.ansible_inventory.filename}') -replace '\\r', '' | Set-Content -NoNewline '${local_file.ansible_inventory.filename}'"
    EOT
  }
}
