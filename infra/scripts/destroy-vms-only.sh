#!/bin/bash
set -e

# === CONFIG ===
INFRA_DIR="infra"
MODULE_NAME="load-balancer"

echo "🔍 Entering Terraform directory..."
cd "$INFRA_DIR"

echo "🔐 Checking state for VM resources..."
terraform state list | grep "$MODULE_NAME.azurerm_linux_virtual_machine" || {
  echo "❌ No VM resources found in state. Are they deployed?"
  exit 1
}

echo "⚠️ Destroying only VM instances inside module.$MODULE_NAME..."
terraform destroy \
  -target=module.$MODULE_NAME.azurerm_linux_virtual_machine.control \
  -target=module.$MODULE_NAME.azurerm_linux_virtual_machine.backend[0] \
  -target=module.$MODULE_NAME.azurerm_linux_virtual_machine.backend[1] \
  -auto-approve

echo "✅ VMs destroyed. Other resources (e.g., SSH keys) are preserved."
