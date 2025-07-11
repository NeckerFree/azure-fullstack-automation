#!/bin/bash
set -e

# === CONFIG ===
JUMP_USER="adminuser"
JUMP_HOST="4.154.243.88"
SSH_KEY_LOCAL="$HOME/.ssh/vm_ssh_key"
REMOTE_DIR="/home/${JUMP_USER}/ansible-setup"
API_SRC_LOCAL="./src"
API_SRC_REMOTE="${REMOTE_DIR}/src"
API_PLAYBOOK_LOCAL="./ansible/api-setup.yml"
TEMPLATE_LOCAL="./ansible/templates/movie-api.service.j2"
TEMPLATE_REMOTE="${REMOTE_DIR}/templates/movie-api.service.j2"
INVENTORY_LOCAL="./ansible/inventory.ini"
INVENTORY_REMOTE="${REMOTE_DIR}/inventory.ini"

# === STEP 0: JUMPBOX_HOST, JUMPBOX_USER validation===
if [ -z "$JUMPBOX_HOST" ] || [ -z "$JUMPBOX_USER" ]; then
  echo "❌ JUMPBOX_HOST or JUMPBOX_USER not defined"
  exit 1
fi

# === STEP 1: Upload playbook and inventory ===
echo "[1/4] Uploading playbook and inventory..."
scp -i "${SSH_KEY_LOCAL}" "${API_PLAYBOOK_LOCAL}" "${INVENTORY_LOCAL}" "${JUMP_USER}@${JUMP_HOST}:${REMOTE_DIR}/"

# [2/4] Copiar código fuente de la API
echo "[2/4] Copiando código fuente de la API..."
scp -r -i "$SSH_KEY_LOCAL" ./src/movie-analyst-api "$JUMPBOX_USER@$JUMPBOX_HOST:/home/$JUMPBOX_USER/ansible-setup/src/"

# === STEP 2: Upload systemd template ===
echo "[3/4] Uploading systemd template..."
ssh -i "${SSH_KEY_LOCAL}" "${JUMP_USER}@${JUMP_HOST}" "mkdir -p ${REMOTE_DIR}/templates"
scp -i "${SSH_KEY_LOCAL}" "${TEMPLATE_LOCAL}" "${JUMP_USER}@${JUMP_HOST}:${TEMPLATE_REMOTE}"

# === STEP 3: Execute playbook remotely ===
echo "[4/4] Executing playbook from the jump host..."
ssh -i "${SSH_KEY_LOCAL}" "${JUMP_USER}@${JUMP_HOST}" << EOF
  set -e
  cd "${REMOTE_DIR}"
  ansible-playbook -i inventory.ini api-setup.yml \
    -e "api_source_path=${API_SRC_REMOTE}" \
    -e "service_name=mysqlmovie-api"
EOF
