variable "location" {
  description = "default location"
  type        = string
  default     = "eastus"
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
