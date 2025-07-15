output "lb_id" {
  description = "ID load balancer"
  value       = azurerm_lb.main.id
}

output "backend_vm_ips" {
  value       = azurerm_linux_virtual_machine.backend[*].private_ip_address
  description = "Private IP addresses of the backend VMs"
}

# Output: URL del Load Balancer para acceder a la API
output "lb_api_url" {
  description = "URL pública para acceder a la API a través del Load Balancer"
  value       = "http://${azurerm_public_ip.lb.ip_address}" # Correct reference
}

output "control_node_public_ip" {
  value       = azurerm_public_ip.control.ip_address
  description = "Public IP address of the control/bastion node"
}

output "network_interface_control_id" {
  value       = azurerm_network_interface.control.id
  description = "network interface id"
}

output "network_interface_control_private_ip" {
  value       = azurerm_network_interface.control.private_ip_address
  description = "jumpbox's private IP"
}

output "private_dns_zone_mysql_id" {
  value       = azurerm_private_dns_zone.mysql.id
  description = "private dns zone mysql id"
}

output "private_dns_zone_mysql_name" {
  value = azurerm_private_dns_zone.mysql.name
}

output "network_interface_backend_0_id" {
  value = azurerm_network_interface.backend[0].id
}

output "network_interface_backend_1_id" {
  value = azurerm_network_interface.backend[1].id
}

output "azurerm_lb_backend_address_pool_api_pool_id" {
  value = azurerm_lb_backend_address_pool.api_pool.id
}
