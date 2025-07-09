variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "bastion_public_ip" {
  type = string
}

variable "allowed_ssh_ip" {
  type = string
}

variable "network_interface_control_id" {
  type = string
}

variable "network_interface_control_private_ip" {
  type = string
}
