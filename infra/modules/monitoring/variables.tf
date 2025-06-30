variable "env_prefix" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "lb_id" { type = string }
variable "enable_free_monitoring" {
  description = "Use free-tier monitoring only"
  type        = bool
  default     = true
}
