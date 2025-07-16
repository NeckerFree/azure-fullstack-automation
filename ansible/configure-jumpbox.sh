#!/bin/bash
set -euo pipefail

# === USO ===
# ./configure-jumpbox.sh <JUMP_HOST> <JUMP_USER> <SSH_KEY_CONTENT> <ANSIBLE_DIR> <REMOTE_DIR>

# === PARÁMETROS ===
JUMP_HOST="$1"
JUMP_USER="$2"
SSH_KEY_CONTENT="$3"
ANSIBLE_DIR="$4"
REMOTE_DIR="$5"

SSH_KEY_PATH="$HOME/.ssh/vm_ssh_key"

echo "📡 Conectando al Jumpbox $JUMP_USER@$JUMP_HOST"
echo "📁 Subiendo archivos desde $ANSIBLE_DIR a $REMOTE_DIR"

# === 1. Configurar SSH localmente con contenido del secreto ===
echo "🔑 Escribiendo la clave SSH localmente..."
mkdir -p ~/.ssh
echo "$SSH_KEY_CONTENT" > "$SSH_KEY_PATH"
chmod 600 "$SSH_KEY_PATH"
echo -e "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile /dev/null\n" > ~/.ssh/config

# === 2. Crear carpeta remota en Jumpbox ===
echo "📁 Creando carpeta en el Jumpbox: $REMOTE_DIR"
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "${JUMP_USER}@${JUMP_HOST}" \
  "mkdir -p ${REMOTE_DIR}"

# === 3. Subir archivos Ansible al Jumpbox ===
echo "⬆️ Subiendo archivos individuales..."
scp -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no \
  "${ANSIBLE_DIR}/setup-infra.yml" "${ANSIBLE_DIR}/inventory.ini" \
  "${ANSIBLE_DIR}/api-setup.yml" "${ANSIBLE_DIR}/db-setup.yml" \
  "${JUMP_USER}@${JUMP_HOST}:${REMOTE_DIR}/"

echo "⬆️ Subiendo carpetas 'templates' y 'files'..."
scp -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -r \
  "${ANSIBLE_DIR}/templates" "${ANSIBLE_DIR}/files" \
  "${JUMP_USER}@${JUMP_HOST}:${REMOTE_DIR}/"

# === 4. Subir clave SSH privada a ~/.ssh/vm_ssh_key en Jumpbox ===
echo "🔐 Subiendo clave SSH privada a Jumpbox..."
scp -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no \
  "$SSH_KEY_PATH" \
  "${JUMP_USER}@${JUMP_HOST}:/home/${JUMP_USER}/.ssh/vm_ssh_key"

ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no \
  "${JUMP_USER}@${JUMP_HOST}" \
  "chmod 600 /home/${JUMP_USER}/.ssh/vm_ssh_key"

# === 5. Ejecutar playbook desde el Jumpbox ===
echo "🚀 Ejecutando playbook desde el Jumpbox..."
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no "${JUMP_USER}@${JUMP_HOST}" << EOF
  set -e
  cd ${REMOTE_DIR}
  if ! command -v ansible-playbook &> /dev/null; then
    echo "🔧 Ansible no encontrado. Instalando..."
    sudo apt update && sudo apt install ansible -y
  fi
  echo "📦 Ejecutando playbook setup-infra.yml..."
  ansible-playbook -i inventory.ini setup-infra.yml -e "ADMIN_USER=${JUMP_USER}"
EOF

echo "✅ Playbook ejecutado exitosamente."
