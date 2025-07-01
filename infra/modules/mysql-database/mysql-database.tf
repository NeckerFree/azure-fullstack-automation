
# variable "subnet_id" { type=string} // azurerm_subnet.db.id
# variable "private_connection_resource_id" { type = string } //azurerm_mysql_flexible_server.movie_analyst.id
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
  # high_availability {
  #   mode = "Disabled"
  # }
  # public_network_access_enabled = false
  depends_on = [var.subnet_id]
}

output "mysql_fqdn" {
  value = azurerm_mysql_flexible_server.mysql.fqdn
}

resource "azurerm_mysql_flexible_database" "movie_analyst" {
  name                = "movie_analyst"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# Execute initialization script
resource "null_resource" "mysql_init" {
  triggers = {
    db_id = azurerm_mysql_flexible_server.mysql.id
  }

  provisioner "local-exec" {
    command = <<EOT
      mysql -h ${azurerm_mysql_flexible_server.mysql.fqdn} \
      -u ${var.admin_username} \
      -p${var.admin_password} \
      < ${path.module}/scripts/movie_analyst_init.sql
    EOT
  }
}

resource "azurerm_private_endpoint" "mysql" {
  name                = "${var.env_prefix}-pe-mysql"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.env_prefix}-psc-mysql"
    private_connection_resource_id = azurerm_mysql_flexible_database.movie_analyst.id
    subresource_names              = ["mysqlServer"]
    is_manual_connection           = false
  }
}
