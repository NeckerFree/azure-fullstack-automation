output "virtual_network_main_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}
output "db_subnet_id" {
  description = "ID of the DB subnet"
  value       = azurerm_subnet.db.id
}

output "backend_subnet_id" {
  description = "ID of the backend subnet"
  value       = azurerm_subnet.backend.id
}


