#!/bin/bash
set -e

# === STEP 0: Read JUMP_HOST and JUMP_USER from inventory ===
INVENTORY_FILE="./ansible/inventory.ini"
JUMP_HOST=$(grep -A1 '^\[control\]' "$INVENTORY_FILE" | tail -n1 | grep -oP 'ansible_host=\K\S+')
JUMP_USER=$(grep -A1 '^\[control\]' "$INVENTORY_FILE" | tail -n1 | grep -oP 'ansible_user=\K\S+')
if [ -z "$JUMP_USER" ] || [ -z "$JUMP_HOST" ]; then
  echo "❌ Could not parse JUMP_USER or JUMP_HOST from inventory.ini"
  exit 1
fi

# === STEP 1: Get Terraform outputs ===
echo "[0/4] Getting outputs from Terraform..."
MYSQL_HOST=$(terraform -chdir=infra output -raw mysql_fqdn)
MYSQL_USER=$(terraform -chdir=infra output -raw mysql_admin_user)
MYSQL_PWD=$(terraform -chdir=infra output -raw mysql_admin_pwd)
MYSQL_DB=$(terraform -chdir=infra output -raw mysql_database_name)

# === STEP 2: Define SSH variables ===
SSH_PORT=22
SSH_KEY_LOCAL="$HOME/.ssh/vm_ssh_key"
PLAYBOOK="ansible/db-setup.yml"
SQL_SCRIPT="ansible/files/mysql/movie_db.sql"
INVENTORY="ansible/inventory.ini"

echo "[1/4] Testing SSH connection to jump host..."
if ! ssh -i "$SSH_KEY_LOCAL" -p $SSH_PORT -o ConnectTimeout=10 -q "$JUMP_USER@$JUMP_HOST" exit; then
  echo "❌ SSH connection failed to $JUMP_HOST:$SSH_PORT"
  exit 1
fi

echo "[1/4] Copying playbook, SQL script and inventory to the jumphost..."
scp -i "$SSH_KEY_LOCAL" -P $SSH_PORT "$PLAYBOOK" "$SQL_SCRIPT" "$INVENTORY" "$JUMP_USER@$JUMP_HOST:/home/$JUMP_USER/"

# === STEP 3: Execute playbook remotely ===
echo "[2/4] Running playbook from jumphost..."
ssh -i "$SSH_KEY_LOCAL" -p $SSH_PORT "$JUMP_USER@$JUMP_HOST" bash <<EOF
  set -e
  echo "Updating packages..."
  sudo apt update -qq
  echo "Installing dependencies..."
  sudo apt install -y ansible mysql-client

  cd /home/$JUMP_USER
  echo "Executing playbook with MySQL credentials..."
  ansible-playbook -i inventory.ini db-setup.yml \
    --extra-vars "db_user=$MYSQL_USER db_password='$MYSQL_PWD' db_name=$MYSQL_DB db_host=$MYSQL_HOST"
EOF

echo "[3/4] Playbook executed successfully!"
