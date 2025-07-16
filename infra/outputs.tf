output "mysql_fqdn" {
  value = module.mysql-database.mysql_fqdn
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
  value = module.mysql-database.mysql_database_name
}

output "lb_api_url" {
  value = module.load-balancer.lb_api_url
}

output "control_node_public_ip" {
  description = "Jumpbox IP"
  value       = module.load-balancer.control_node_public_ip
}

output "ssh_user" {
  description = "SSH admin user for VMs"
  value       = var.admin_username
}
