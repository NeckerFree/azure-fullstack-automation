#!/bin/bash
set -e

# === CONFIG ===
INFRA_DIR="infra"
MODULE_NAME="load-balancer"

echo "🔍 Entering Terraform directory..."
cd "$INFRA_DIR"


echo "Applying write_ssh_key_once $MODULE_NAME..."
terraform apply \
  -target=module.$MODULE_NAME.null_resource.write_ssh_key_once \
  -auto-approve

echo "✅ Apply Ok"
