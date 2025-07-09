#!/bin/bash

set -e

# 🧠 Terraform outputs
echo "[0/5] Obteniendo outputs desde Terraform..."
MYSQL_HOST=$(terraform output -raw mysql_fqdn)
MYSQL_USER=$(terraform output -raw mysql_admin_user)
MYSQL_PWD=$(terraform output -raw mysql_admin_pwd)
MYSQL_DB=$(terraform output -raw mysql_database_name)

# 📡 SSH y rutas
JUMPBOX_IP="4.246.105.113"
JUMPBOX_USER="adminuser"
SSH_KEY_LOCAL="$HOME/.ssh/vm_ssh_key"
PLAYBOOK="ansible/db-setup.yml"
SQL_SCRIPT="ansible/files/mysql/movie_db.sql"
INVENTORY="ansible/inventory.ini"

# 📤 Envío de archivos
echo "[1/5] Copiando playbook y script SQL a la jumphost..."
scp -i "$SSH_KEY" "$PLAYBOOK" "$SQL_SCRIPT" "$JUMPBOX_USER@$JUMPBOX_IP:/home/$JUMPBOX_USER/"

echo "[2/5] Copiando archivo de inventario..."
scp -i "$SSH_KEY" "$INVENTORY" "$JUMPBOX_USER@$JUMPBOX_IP:/home/$JUMPBOX_USER/"

# 🧪 Ejecución remota con Ansible
echo "[3/5] Ejecutando playbook desde la jumphost..."
ssh -i "$SSH_KEY" "$JUMPBOX_USER@$JUMPBOX_IP" bash <<EOF
  set -e
  sudo apt update -qq
  sudo apt install -y ansible
  ansible-playbook -i inventory.ini db-setup.yml \
    --extra-vars "db_user=$MYSQL_USER db_password=$MYSQL_PWD db_name=$MYSQL_DB db_host=$MYSQL_HOST"
EOF

echo "[4/5] ¡Playbook ejecutado exitosamente en la jumphost!"
