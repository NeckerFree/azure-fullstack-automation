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


variable "jumpbox_private_ip" {
  type = string
}

variable "network_interface_backend_0_id" {
  type = string
}

variable "network_interface_backend_1_id" {
  type = string
}
