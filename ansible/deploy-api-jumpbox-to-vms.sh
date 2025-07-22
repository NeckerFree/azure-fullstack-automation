#!/bin/bash
set -e

# === EXPORT DB ENV VARS from outer scope ===
DB_HOST=${DB_HOST:-$1}
DB_USER=${DB_USER:-$2}
DB_PASS=${DB_PASS:-$3}
DB_NAME=${DB_NAME:-$4}
JUMP_HOST=${JUMP_HOST:-$5}
JUMP_USER=${JUMP_USER:-$6}

# === CONFIG ===
# === STEP 0: Read JUMP_HOST and JUMP_USER from inventory ===
INVENTORY_FILE="./ansible/inventory.ini"


SSH_KEY_LOCAL="$HOME/.ssh/vm_ssh_key"
REMOTE_DIR="/home/${JUMP_USER}/ansible-setup"
API_SRC_LOCAL="./src/movie-analyst-api"
API_SRC_REMOTE="${REMOTE_DIR}/src/movie-analyst-api"
TEMPLATE_LOCAL="./ansible/templates/movie-api.service.j2"
TEMPLATE_REMOTE="${REMOTE_DIR}/templates/movie-api.service.j2"


# === STEP 0: Validate jumpbox configuration ===
if [ -z "$JUMP_USER" ] || [ -z "$JUMP_HOST" ]; then
  echo "❌ JUMP_USER or JUMP_HOST not defined"
  exit 1
fi

# === STEP 2: Copy API source code ===
echo "[2/4] Copying API source code..."
ssh -i "$SSH_KEY_LOCAL" "$JUMP_USER@$JUMP_HOST" "mkdir -p ${REMOTE_DIR}/src"
scp -i "$SSH_KEY_LOCAL" -r "$API_SRC_LOCAL" "$JUMP_USER@$JUMP_HOST:${REMOTE_DIR}/src/"

# === STEP 3: Upload systemd template ===
echo "[3/4] Uploading systemd template..."
ssh -i "${SSH_KEY_LOCAL}" "${JUMP_USER}@${JUMP_HOST}" "mkdir -p ${REMOTE_DIR}/templates"
scp -i "${SSH_KEY_LOCAL}" "${TEMPLATE_LOCAL}" "${JUMP_USER}@${JUMP_HOST}:${TEMPLATE_REMOTE}"

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
echo "🔎 Verificando envs en jumpbox:"
# echo "DB_HOST=${DB_HOST}"
# echo "DB_USER=${DB_USER}"
# echo "DB_PASS=${DB_PASS}"
# echo "DB_NAME=${DB_NAME}"

ssh -i "${SSH_KEY_LOCAL}" "${JUMP_USER}@${JUMP_HOST}" <<EOF
  set -e
  export DB_HOST="${DB_HOST}"
  export DB_USER="${DB_USER}"
  export DB_PASS="${DB_PASS}"
  export DB_NAME="${DB_NAME}"

  # echo "🔍 [jumpbox] DB_HOST=\$DB_HOST"
  # echo "🔍 [jumpbox] DB_USER=\$DB_USER"

  cd "${REMOTE_DIR}"
  ansible-playbook -i inventory.ini api-setup.yml \
  -e "api_source_path=${API_SRC_REMOTE}" \
  -e "service_name=movie-api" \
  -e "db_host='${DB_HOST}'" \
  -e "db_user='${DB_USER}'" \
  -e "db_password='${DB_PASS}'" \
  -e "db_name='${DB_NAME}'" \
  -e "admin_user='${JUMP_USER}'" 
EOF


