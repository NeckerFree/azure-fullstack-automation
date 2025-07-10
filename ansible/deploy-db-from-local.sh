#!/bin/bash

set -e

# 📥 Obtener outputs de Terraform localmente
echo "[0/4] Obteniendo outputs desde Terraform..."
MYSQL_HOST=$(terraform -chdir=infra/modules/mysql-database output -raw mysql_fqdn)
MYSQL_USER=$(terraform -chdir=infra/modules/mysql-database output -raw mysql_admin_user)
MYSQL_PWD=$(terraform -chdir=infra/modules/mysql-database output -raw mysql_admin_pwd)
MYSQL_DB=$(terraform -chdir=infra/modules/mysql-database output -raw mysql_database_name)

# 📡 SSH y rutas
JUMPBOX_IP="4.155.204.253"
JUMPBOX_USER="adminuser"
SSH_KEY_LOCAL="$HOME/.ssh/vm_ssh_key"
PLAYBOOK="ansible/db-setup.yml"
SQL_SCRIPT="ansible/files/mysql/movie_db.sql"
INVENTORY="ansible/inventory.ini"

# 📤 Enviar archivos a la jumphost
echo "[1/3] Copiando playbook, SQL script e inventario a la jumphost..."
scp -i "$SSH_KEY_LOCAL" "$PLAYBOOK" "$SQL_SCRIPT" "$INVENTORY" "$JUMPBOX_USER@$JUMPBOX_IP:/home/$JUMPBOX_USER/"

# 🧪 Ejecutar playbook remotamente
echo "[2/3] Ejecutando playbook desde la jumphost..."
ssh -i "$SSH_KEY_LOCAL" "$JUMPBOX_USER@$JUMPBOX_IP" bash <<EOF
  set -e
  sudo apt update -qq
  sudo apt install -y ansible mysql-client
  ansible-playbook -i inventory.ini db-setup.yml \
    --extra-vars "db_user=$MYSQL_USER db_password=$MYSQL_PWD db_name=$MYSQL_DB db_host=$MYSQL_HOST"
EOF

echo "[3/3] ¡Playbook ejecutado exitosamente!"


