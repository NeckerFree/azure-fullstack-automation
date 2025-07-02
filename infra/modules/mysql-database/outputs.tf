
output "mysql_fqdn" {
  value       = azurerm_mysql_flexible_server.mysql.fqdn
  description = "MySQL server fully qualified domain name"
}

output "mysql_admin_user" {
  value       = azurerm_mysql_flexible_server.mysql.administrator_login
  description = "MySQL admin username"
  sensitive   = true
}

output "mysql_database_name" {
  value       = azurerm_mysql_flexible_database.movie_analyst.name
  description = "MySQL database name"
}
