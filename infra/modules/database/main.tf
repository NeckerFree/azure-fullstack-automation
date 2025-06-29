variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "env_prefix" { type = string }
variable "subnet_id" { type = string }
variable "admin_username" { type = string }
variable "admin_password" { type = string }
variable "normalized_workspace" { type = string }
resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "${var.env_prefix}-mysql"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  sku_name               = var.normalized_workspace == "prod" ? "GP_Standard_D2ds_v4" : "B_Standard_B1ms"
  version                = "8.0.21"

  storage {
    size_gb = var.normalized_workspace == "prod" ? 256 : 20
  }
  high_availability {
    mode = "Disabled"
  }

  depends_on = [var.subnet_id]
}

output "mysql_fqdn" {
  value = azurerm_mysql_flexible_server.mysql.fqdn
}

resource "azurerm_mysql_flexible_database" "movie_analyst" {
  name                = "movie_analyst"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.movie_analyst.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# Execute initialization script
resource "null_resource" "mysql_init" {
  triggers = {
    db_id = azurerm_mysql_flexible_server.movie_analyst.id
  }

  provisioner "local-exec" {
    command = <<EOT
      mysql -h ${azurerm_mysql_flexible_server.movie_analyst.fqdn} \
      -u ${azurerm_mysql_flexible_server.movie_analyst.administrator_login} \
      -p${admin_password} \
      < ${path.module}/scripts/movie_analyst_init.sql
    EOT
  }
}
