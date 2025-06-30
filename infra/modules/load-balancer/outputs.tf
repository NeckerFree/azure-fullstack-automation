output "lb_id" {
  description = "ID load balancer"
  value       = azurerm_lb.main.id
}

output "backend_vm_ips" {
  value       = azurerm_linux_virtual_machine.backend[*].private_ip_address
  description = "Private IP addresses of the backend VMs"
}
