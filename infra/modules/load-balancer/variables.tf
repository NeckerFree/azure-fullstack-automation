variable "env_prefix" { type = string }
variable "environment" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "virtual_network_main_id" { type = string }
variable "backend_subnet_id" { type = string }
variable "mysql_fqdn" { type = string }
variable "admin_username" { type = string }

variable "ssh_public_key" {
  description = "Public SSH key to access VMs"
  type        = string
}

variable "lb_api_port" {
  description = "Puerto en el que expone el Load Balancer el API"
  type        = number
  default     = 8080
}
