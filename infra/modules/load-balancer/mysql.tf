resource "azurerm_private_dns_zone" "mysql" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "${var.env_prefix}-mysql-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = var.virtual_network_id
}
