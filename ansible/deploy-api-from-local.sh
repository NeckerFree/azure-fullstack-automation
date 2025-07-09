#!/bin/bash

# === CONFIGURACIÓN ===
JUMP_USER="adminuser"
JUMP_HOST="4.246.105.113"
SSH_KEY_LOCAL="ansible/vm_ssh_key"
REMOTE_DIR="/home/${JUMP_USER}/ansible-setup"
API_SRC_LOCAL="./src"
API_SRC_REMOTE="${REMOTE_DIR}/src"
API_PLAYBOOK_LOCAL="./ansible/api-setup.yml"
TEMPLATE_LOCAL="./ansible/templates/movie-api.service.j2"
TEMPLATE_REMOTE="${REMOTE_DIR}/templates/movie-api.service.j2"

# === PASO 1: Subir playbook api-setup.yml ===
echo "[1/3] Subiendo playbook api-setup.yml..."
scp -i ${SSH_KEY_LOCAL} "${API_PLAYBOOK_LOCAL}" "${JUMP_USER}@${JUMP_HOST}:${REMOTE_DIR}/api-setup.yml"

# === PASO 2: Subir plantilla del servicio systemd ===
echo "[2/3] Subiendo plantilla systemd..."
ssh -i ${SSH_KEY_LOCAL} ${JUMP_USER}@${JUMP_HOST} "mkdir -p ${REMOTE_DIR}/templates"
scp -i ${SSH_KEY_LOCAL} "${TEMPLATE_LOCAL}" "${JUMP_USER}@${JUMP_HOST}:${TEMPLATE_REMOTE}"

# === PASO 3: Ejecutar el playbook desde la jumphost ===
echo "[3/3] Ejecutando playbook desde la jumphost..."
ssh -i ${SSH_KEY_LOCAL} ${JUMP_USER}@${JUMP_HOST} << EOF
  cd ${REMOTE_DIR}
  ansible-playbook -i inventory.ini api-setup.yml -e "api_source_path=${API_SRC_REMOTE}" -e "service_name=mysqlmovie-api"
EOF
