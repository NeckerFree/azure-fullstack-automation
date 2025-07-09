#!/bin/bash

# === CONFIGURACIÓN ===
JUMP_USER="adminuser"
JUMP_HOST="4.246.105.113"
SSH_KEY_LOCAL="$HOME/.ssh/vm_ssh_key"
REMOTE_DIR="/home/${JUMP_USER}/ansible-setup"
SETUP_PLAYBOOK_FILE="setup-infra.yml"

# === PASO 1: Crear directorio remoto en la jumphost ===
echo "[1/5] Creando directorio remoto en la jumphost..."
ssh -i ${SSH_KEY_LOCAL} ${JUMP_USER}@${JUMP_HOST} "mkdir -p ${REMOTE_DIR}"

# === PASO 2: Subir playbook corregido a la jumphost ===
echo "[2/5] Subiendo playbook corregido a la jumphost..."
cat > /tmp/temp-setup-infra.yml <<'EOF'
---
- name: Configure infrastructure
  hosts: all
  gather_facts: false
  tasks:
    - name: Ensure all nodes are in /etc/hosts
      become: yes
      ansible.builtin.lineinfile:
        path: /etc/hosts
        line: "{{ hostvars[item].ansible_host | default(item) }} {{ item }}"
        state: present
      loop: "{{ groups['all'] }}"

- name: Configure control node ssh
  hosts: control
  gather_facts: false
  vars:
    ssh_private_key_path: "/home/adminuser/.ssh/id_rsa"
  tasks:
    - name: Create ~/.ssh directory
      ansible.builtin.file:
        path: ~/.ssh
        state: directory
        mode: "0700"

    - name: Update SSH config for node* hosts
      ansible.builtin.blockinfile:
        path: ~/.ssh/config
        block: |
          Host node*
            StrictHostKeyChecking no
            UserKnownHostsFile /dev/null
            User adminuser
            IdentityFile {{ ssh_private_key_path }}
        marker: "# {mark} ANSIBLE MANAGED BLOCK - NODE CONFIG"
        create: yes
EOF

scp -i ${SSH_KEY_LOCAL} /tmp/temp-setup-infra.yml ${JUMP_USER}@${JUMP_HOST}:${REMOTE_DIR}/${SETUP_PLAYBOOK_FILE}
rm /tmp/temp-setup-infra.yml

# === PASO 3: Generar inventory.ini corregido en la jumphost ===
echo "[3/5] Generando inventory.ini corregido en la jumphost..."
ssh -i ${SSH_KEY_LOCAL} ${JUMP_USER}@${JUMP_HOST} << 'EOF'
cat > /home/adminuser/ansible-setup/inventory.ini <<EOL
[control]
localhost ansible_connection=local

[nodes]
epamqa-vm-api-0 ansible_host=10.0.2.5 ansible_user=adminuser ansible_ssh_private_key_file=/home/adminuser/.ssh/vm_ssh_key ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
epamqa-vm-api-1 ansible_host=10.0.2.6 ansible_user=adminuser ansible_ssh_private_key_file=/home/adminuser/.ssh/vm_ssh_key ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

[all:vars]
ansible_connection=ssh
ansible_ssh_timeout=60
ansible_python_interpreter=/usr/bin/python3
EOL
EOF
# === PASO 3.5: Subir clave SSH a la jumphost ===
echo "[3.5/5] Subiendo clave SSH a la jumphost..."
scp -i ${SSH_KEY_LOCAL} ${SSH_KEY_LOCAL} ${JUMP_USER}@${JUMP_HOST}:/home/${JUMP_USER}/.ssh/vm_ssh_key

# === PASO 4: Asegurar permisos de la clave SSH ===
echo "[4/5] Asegurando permisos de la clave SSH en la jumphost..."
ssh -i ${SSH_KEY_LOCAL} ${JUMP_USER}@${JUMP_HOST} "chmod 600 ~/.ssh/vm_ssh_key"

# === PASO 5: Ejecutar Ansible desde la jumphost ===
echo "[5/5] Ejecutando playbook desde la jumphost..."
ssh -i ${SSH_KEY_LOCAL} ${JUMP_USER}@${JUMP_HOST} << EOF
  cd ${REMOTE_DIR}
  if ! command -v ansible-playbook &> /dev/null; then
    echo "Instalando Ansible en la jumphost..."
    sudo apt update && sudo apt install ansible -y
  fi
  echo "Ejecutando playbook..."
  ansible-playbook -i inventory.ini ${SETUP_PLAYBOOK_FILE}
EOF
