
# variable "subnet_id" { type=string} // azurerm_subnet.db.id
# variable "private_connection_resource_id" { type = string } //azurerm_mysql_flexible_server.movie_analyst.id
resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "${var.env_prefix}-mysql-${var.location}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.mysql_user
  administrator_password = var.mysql_admin_password
  sku_name               = var.environment == "prod" ? "GP_Standard_D2ds_v4" : "B_Standard_B1ms"
  version                = "8.0.21"

  storage {
    size_gb = var.environment == "prod" ? 256 : 20
  }
  # high_availability {
  #   mode = "Disabled"
  # }
  # public_network_access_enabled = false
  depends_on = [var.subnet_id]
}

resource "azurerm_mysql_flexible_database" "movie_analyst" {
  name                = "movie_analyst"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
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
