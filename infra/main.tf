
locals {
  company              = "epam"
  normalized_workspace = terraform.workspace == "default" ? "dev" : lower(terraform.workspace)
  name_prefix          = "${local.company}-${local.normalized_workspace}"
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
  source               = "./modules/network"
  resource_group_name  = azurerm_resource_group.state.name
  location             = local.location
  env_prefix           = local.name_prefix
  normalized_workspace = local.normalized_workspace
}

module "database" {
  source               = "./modules/database"
  resource_group_name  = var.resource_group_name
  location             = var.location
  env_prefix           = local.name_prefix
  subnet_id            = module.network.db_subnet_id
  normalized_workspace = local.normalized_workspace
  admin_username       = var.mysql_user
  admin_password       = var.mysql_admin_password
}

module "load-balancer" {
  source                     = "./modules/load-balancer"
  location                   = var.location
  env_prefix                 = local.name_prefix
  normalized_workspace       = local.normalized_workspace
  resource_group_name        = var.resource_group_name
  virtual_network_id         = module.network.virtual_network_id
  backend_subnet_id          = module.network.backend_subnet_id
  mysql_flexible_server_fqdn = module.database.mysql_flexible_server_fqdn
}


module "monitoring" {
  source              = "./modules/monitoring"
  location            = var.location
  resource_group_name = var.resource_group_name
  lb_id               = module.load-balancer.lb_id
  env_prefix          = local.name_prefix
}
