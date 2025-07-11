variable "location" {
  description = "default location"
  type        = string
  default     = "westus2"
}
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Azure Service Principal App ID"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Azure Service Principal Secret"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
}

variable "mysql_admin_password" {
  type      = string
  sensitive = true
}

variable "mysql_user" {
  type      = string
  sensitive = true
}

variable "admin_username" {
  default = "adminuser"
}

variable "allowed_ssh_ip" {
  type      = string
  sensitive = true
}


