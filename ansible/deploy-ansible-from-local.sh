#!/bin/bash

##!/bin/bash

# === CONFIGURACIÓN ===
INVENTORY_FILE="inventory.ini"
JUMP_HOST=$(awk '/^\[control\]/ {getline; match($0, /ansible_host=([^ ]+)/, m); print m[1]}' "$INVENTORY_FILE")
JUMP_USER=$(awk '/^\[control\]/ {getline; match($0, /ansible_user=([^ ]+)/, m); print m[1]}' "$INVENTORY_FILE")
if [ -z "$JUMP_USER" ] || [ -z "$JUMP_HOST" ]; then
  echo "❌ Could not parse JUMP_USER or JUMP_HOST from inventory.ini"
  exit 1
fi

SSH_KEY_LOCAL="$HOME/.ssh/vm_ssh_key"
REMOTE_DIR="/home/${JUMP_USER}/ansible-setup"
SETUP_PLAYBOOK_FILE="setup-infra.yml"

# === PASO 1: Subir clave SSH a la jumphost ===
echo "[1/3] Subiendo clave SSH a la jumphost..."
scp -i ${SSH_KEY_LOCAL} ${SSH_KEY_LOCAL} ${JUMP_USER}@${JUMP_HOST}:/home/${JUMP_USER}/.ssh/vm_ssh_key

# === PASO 2: Asegurar permisos de la clave SSH ===
echo "[2/3] Asegurando permisos de la clave SSH en la jumphost..."
ssh -i ${SSH_KEY_LOCAL} ${JUMP_USER}@${JUMP_HOST} "chmod 600 ~/.ssh/vm_ssh_key"

# === PASO 3: Ejecutar Ansible desde la jumphost ===
echo "[3/3] Ejecutando playbook desde la jumphost..."
ssh -i ${SSH_KEY_LOCAL} ${JUMP_USER}@${JUMP_HOST} << EOF
  cd ${REMOTE_DIR}
  if ! command -v ansible-playbook &> /dev/null; then
    echo "Instalando Ansible en la jumphost..."
    sudo apt update && sudo apt install ansible -y
  fi
  echo "Ejecutando playbook..."
  ansible-playbook -i inventory.ini ${SETUP_PLAYBOOK_FILE}
EOF
