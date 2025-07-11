
resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "${var.env_prefix}-mysql-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = var.private_dns_zone_mysql_name
  virtual_network_id    = var.virtual_network_main_id
  registration_enabled  = false
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "${var.env_prefix}-mysql-${var.location}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.mysql_user
  administrator_password = var.mysql_admin_password
  sku_name               = var.environment == "prod" ? "GP_Standard_D2ds_v4" : "B_Standard_B1ms"
  version                = "8.0.21"
  delegated_subnet_id    = var.subnet_db_id
  private_dns_zone_id    = var.private_dns_zone_mysql_id
  storage {
    size_gb = var.environment == "prod" ? 256 : 20
  }
  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql]
}

resource "azurerm_mysql_flexible_database" "movie_analyst" {
  name                = "movie_analyst"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}
