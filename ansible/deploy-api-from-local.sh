#!/bin/bash
set -e

# === CONFIG ===
# === STEP 0: Read JUMP_HOST and JUMP_USER from inventory ===
INVENTORY_FILE="./ansible/inventory.ini"
JUMP_HOST=$(awk '/^\[control\]/ {getline; match($0, /ansible_host=([^ ]+)/, m); print m[1]}' "$INVENTORY_FILE")
JUMP_USER=$(awk '/^\[control\]/ {getline; match($0, /ansible_user=([^ ]+)/, m); print m[1]}' "$INVENTORY_FILE")
if [ -z "$JUMP_USER" ] || [ -z "$JUMP_HOST" ]; then
  echo "❌ Could not parse JUMP_USER or JUMP_HOST from inventory.ini"
  exit 1
fi

SSH_KEY_LOCAL="$HOME/.ssh/vm_ssh_key"
REMOTE_DIR="/home/${JUMP_USER}/ansible-setup"
API_SRC_LOCAL="./src/movie-analyst-api"
API_SRC_REMOTE="${REMOTE_DIR}/src/movie-analyst-api"
API_PLAYBOOK_LOCAL="./ansible/api-setup.yml"
TEST_PLAYBOOK_LOCAL="./ansible/connection-test.yml"
TEMPLATE_LOCAL="./ansible/templates/movie-api.service.j2"
TEMPLATE_REMOTE="${REMOTE_DIR}/templates/movie-api.service.j2"
INVENTORY_LOCAL="./ansible/inventory.ini"
INVENTORY_REMOTE="${REMOTE_DIR}/inventory.ini"

# === STEP 0: Validate jumpbox configuration ===
if [ -z "$JUMP_USER" ] || [ -z "$JUMP_HOST" ]; then
  echo "❌ JUMP_USER or JUMP_HOST not defined"
  exit 1
fi

# === STEP 1: Upload playbook, test connection and inventory ===
echo "[1/4] Uploading playbook and inventory..."
scp -i "${SSH_KEY_LOCAL}" "${API_PLAYBOOK_LOCAL}" "${TEST_PLAYBOOK_LOCAL}" "${INVENTORY_LOCAL}" "${JUMP_USER}@${JUMP_HOST}:${REMOTE_DIR}/"

# === STEP 2: Copy API source code ===
echo "[2/4] Copying API source code..."
ssh -i "$SSH_KEY_LOCAL" "$JUMP_USER@$JUMP_HOST" "mkdir -p ${REMOTE_DIR}/src"
scp -i "$SSH_KEY_LOCAL" -r "$API_SRC_LOCAL" "$JUMP_USER@$JUMP_HOST:${REMOTE_DIR}/src/"

# === STEP 3: Upload systemd template ===
# echo "[3/4] Uploading systemd template..."
# ssh -i "${SSH_KEY_LOCAL}" "${JUMP_USER}@${JUMP_HOST}" "mkdir -p ${REMOTE_DIR}/templates"
# scp -i "${SSH_KEY_LOCAL}" "${TEMPLATE_LOCAL}" "${JUMP_USER}@${JUMP_HOST}:${TEMPLATE_REMOTE}"

# === STEP 3.5: Preload known_hosts in the jumpbox to avoid host key verification ===
echo "[3.5/4] Adding backend VM keys to known_hosts on the jumpbox..."
ssh -i "${SSH_KEY_LOCAL}" "${JUMP_USER}@${JUMP_HOST}" bash <<'EOF'
  set -e
  # Parse inventory to get IPs and add them to known_hosts
  for ip in $(grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' inventory.ini); do
    ssh-keyscan -H "$ip" >> ~/.ssh/known_hosts 2>/dev/null || true
  done
EOF

# === STEP 3.7: Validate database environment variables ===
if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASS" || -z "$DB_NAME" ]]; then
  echo "❌ Missing database environment variables"
  exit 1
fi

# === STEP 4: Execute playbook remotely ===
echo "[4/4] Executing playbook from the jump host..."
ssh -i "${SSH_KEY_LOCAL}" "${JUMP_USER}@${JUMP_HOST}" << EOF
  set -e
  cd "${REMOTE_DIR}"
  ansible-playbook -i inventory.ini api-setup.yml \
  -e "api_source_path=${API_SRC_REMOTE}" \
  -e "service_name=mysqlmovie-api" \
  -e "db_host=${DB_HOST}" \
  -e "db_user=${DB_USER}" \
  -e "db_password=${DB_PASS}" \
  -e "db_name=${DB_NAME}"
EOF

