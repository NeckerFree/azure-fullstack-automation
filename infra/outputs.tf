output "mysql_fqdn" {
  value     = module.mysql-database.mysql_fqdn
  sensitive = true
}

output "mysql_admin_user" {
  value     = module.mysql-database.mysql_admin_user
  sensitive = true
}

output "mysql_admin_pwd" {
  value     = module.mysql-database.mysql_admin_pwd
  sensitive = true
}

output "mysql_database_name" {
  value     = module.mysql-database.mysql_database_name
  sensitive = true
}

output "lb_api_url" {
  value     = module.load-balancer.lb_api_url
  sensitive = true
}

output "control_node_public_ip" {
  description = "Jumpbox IP"
  value       = module.load-balancer.control_node_public_ip
  sensitive   = true
}

output "ssh_user" {
  description = "SSH admin user for VMs"
  value       = var.admin_username
  sensitive   = true
}

output "app_service_name" {
  value     = module.app-service.app_service_name
  sensitive = false
}

output "resource_group_name" {
  value     = local.resource_group_name
  sensitive = false
}
