
locals {
  company              = "epam"
  normalized_workspace = terraform.workspace == "default" ? "dev" : lower(terraform.workspace)
  name_prefix          = "${local.company}_${local.normalized_workspace}"
  location             = var.location
}

resource "azurerm_resource_group" "state" {
  name     = "${local.name_prefix}-rg"
  location = local.location
  tags = {
    Workspace = local.normalized_workspace
  }
}

module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.state.name
  location            = local.location
  env_suffix          = local.normalized_workspace
}

module "mysql" {
  source               = "./modules/database"
  resource_group_name  = var.resource_group_name
  location             = var.location
  env_prefix           = local.name_prefix
  subnet_id            = azurerm_subnet.db.id
  normalized_workspace = local.normalized_workspace
  admin_username       = var.mysql_user
  admin_password       = var.mysql_admin_password
}
