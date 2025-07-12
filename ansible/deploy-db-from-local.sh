#!/bin/bash
set -e

# === STEP 0: Read JUMP_HOST and JUMP_USER from inventory ===
INVENTORY_FILE="./ansible/inventory.ini"
JUMP_HOST=$(awk '/^\[control\]/ {getline; match($0, /ansible_host=([^ ]+)/, m); print m[1]}' "$INVENTORY_FILE")
JUMP_USER=$(awk '/^\[control\]/ {getline; match($0, /ansible_user=([^ ]+)/, m); print m[1]}' "$INVENTORY_FILE")
if [ -z "$JUMP_USER" ] || [ -z "$JUMP_HOST" ]; then
  echo "❌ Could not parse JUMP_USER or JUMP_HOST from inventory.ini"
  exit 1
fi

# [0/4] Get Terraform outputs
echo "[0/4] Getting outputs from Terraform..."
MYSQL_HOST=$(terraform -chdir=infra output -raw mysql_fqdn)
MYSQL_USER=$(terraform -chdir=infra output -raw mysql_admin_user)
MYSQL_PWD=$(terraform -chdir=infra output -raw mysql_admin_pwd)
MYSQL_DB=$(terraform -chdir=infra output -raw mysql_database_name)

# [1/4] Define SSH paths and variables
SSH_KEY_LOCAL="$HOME/.ssh/vm_ssh_key"
PLAYBOOK="ansible/db-setup.yml"
SQL_SCRIPT="ansible/files/mysql/movie_db.sql"
INVENTORY="ansible/inventory.ini"

echo "[1/4] Copying playbook, SQL script and inventory to the jumphost..."
scp -i "$SSH_KEY_LOCAL" "$PLAYBOOK" "$SQL_SCRIPT" "$INVENTORY" "$JUMPBOX_USER@$JUMPBOX_HOST:/home/$JUMPBOX_USER/"

# [2/4] Execute playbook from jumphost
echo "[2/4] Running playbook from jumphost..."
ssh -i "$SSH_KEY_LOCAL" "$JUMPBOX_USER@$JUMPBOX_HOST" bash <<EOF
  set -e
  sudo apt update -qq
  sudo apt install -y ansible mysql-client
  ansible-playbook -i inventory.ini db-setup.yml \
    --extra-vars "db_user=$MYSQL_USER db_password=$MYSQL_PWD db_name=$MYSQL_DB db_host=$MYSQL_HOST"
EOF

echo "[3/4] Playbook executed successfully!"