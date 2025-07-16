#!/bin/bash
set -euo pipefail

# === USO ===
# ./configure-jumpbox.sh <JUMP_HOST> <JUMP_USER> <SSH_KEY_PATH> <ANSIBLE_DIR> <REMOTE_DIR>

# === PARÁMETROS ===
JUMP_HOST="$1"
JUMP_USER="$2"
SSH_KEY_PATH="$3"
ANSIBLE_DIR="$4"
REMOTE_DIR="$5"

echo "📡 Conectando al Jumpbox $JUMP_USER@$JUMP_HOST usando la llave $SSH_KEY_PATH"
echo "📁 Subiendo archivos desde $ANSIBLE_DIR a $REMOTE_DIR"

# === 1. Configurar SSH localmente ===
echo "🔑 Configurando llave SSH localmente..."
mkdir -p ~/.ssh
cp "$SSH_KEY_PATH" ~/.ssh/vm_ssh_key
chmod 600 ~/.ssh/vm_ssh_key
echo -e "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile /dev/null\n" > ~/.ssh/config

# === 2. Crear carpeta remota en Jumpbox ===
echo "📁 Creando carpeta en el Jumpbox: $REMOTE_DIR"
ssh -i ~/.ssh/vm_ssh_key -o StrictHostKeyChecking=no "${JUMP_USER}@${JUMP_HOST}" \
  "mkdir -p ${REMOTE_DIR}"

# === 3. Subir archivos Ansible al Jumpbox ===
echo "⬆️ Subiendo archivos individuales..."
scp -i ~/.ssh/vm_ssh_key -o StrictHostKeyChecking=no \
  "${ANSIBLE_DIR}/setup-infra.yml" "${ANSIBLE_DIR}/inventory.ini" \
  "${ANSIBLE_DIR}/api-setup.yml" "${ANSIBLE_DIR}/db-setup.yml" \
  "${JUMP_USER}@${JUMP_HOST}:${REMOTE_DIR}/"

echo "⬆️ Subiendo carpetas 'templates' y 'files'..."
scp -i ~/.ssh/vm_ssh_key -o StrictHostKeyChecking=no -r \
  "${ANSIBLE_DIR}/templates" "${ANSIBLE_DIR}/files" \
  "${JUMP_USER}@${JUMP_HOST}:${REMOTE_DIR}/"

# === 4. Subir clave SSH privada a Jumpbox ===
echo "🔐 Subiendo clave SSH privada a ~/.ssh/vm_ssh_key en el Jumpbox..."
scp -i ~/.ssh/vm_ssh_key -o StrictHostKeyChecking=no \
  ~/.ssh/vm_ssh_key \
  "${JUMP_USER}@${JUMP_HOST}:/home/${JUMP_USER}/.ssh/vm_ssh_key"

ssh -i ~/.ssh/vm_ssh_key -o StrictHostKeyChecking=no \
  "${JUMP_USER}@${JUMP_HOST}" \
  "chmod 600 /home/${JUMP_USER}/.ssh/vm_ssh_key"

# === 5. Ejecutar Ansible desde el Jumpbox ===
echo "🚀 Ejecutando playbook desde el Jumpbox..."

ssh -i ~/.ssh/vm_ssh_key -o StrictHostKeyChecking=no "${JUMP_USER}@${JUMP_HOST}" << EOF
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
