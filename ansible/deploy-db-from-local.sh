#!/bin/bash
set -e


# [1/4] Define SSH paths and variables
DB_HOST=${DB_HOST:-$1}
DB_USER=${DB_USER:-$2}
DB_PASS=${DB_PASS:-$3}
DB_NAME=${DB_NAME:-$4}
JUMP_HOST=${JUMP_HOST:-$5}
JUMP_USER=${JUMP_USER:-$6}
SSH_PORT="22"
SSH_KEY_LOCAL="$HOME/.ssh/vm_ssh_key"
# SQL_SCRIPT="ansible/files/mysql/movie_db.sql"
# INVENTORY="ansible/inventory.ini"

# echo "[1/4] Testing SSH connection to jump host..."
# if ! ssh -i "$SSH_KEY_LOCAL" -p $SSH_PORT -o ConnectTimeout=10 -q "$JUMP_USER@$JUMP_HOST" exit; then
#   echo "❌ SSH connection failed to $JUMP_HOST:$SSH_PORT"
#   echo "Please verify:"
#   echo "1. The VM is running"
#   echo "2. NSG allows port $SSH_PORT"
#   echo "3. Correct key is at $SSH_KEY_LOCAL"
#   exit 1
# fi

# echo "[1/4] Copying playbook, SQL script and inventory to the jumphost..."
scp -i "$SSH_KEY_LOCAL" -o StrictHostKeyChecking=no \
  ./ansible/db-setup.yml "$JUMP_USER@$JUMP_HOST:/home/$JUMP_USER/ansible-setup/"

echo "[2/4] Running playbook from jumphost..."
ssh -i "$SSH_KEY_LOCAL" -p "$SSH_PORT" "$JUMP_USER@$JUMP_HOST" bash <<EOF
  set -e
  echo "Updating packages..."
  sudo apt update -qq
  echo "Installing dependencies..."
  sudo apt install -y ansible mysql-client
  cd /home/$JUMP_USER/ansible-setup
  echo "Executing playbook..."
  ansible-playbook -i inventory.ini db-setup.yml \
    --extra-vars "db_user='${DB_USER}' db_password='${DB_PASS}' db_name='${DB_NAME}' db_host='${DB_HOST}' jump_user=''${JUMP_USER}"
EOF

echo "[3/4] Playbook executed successfully!"