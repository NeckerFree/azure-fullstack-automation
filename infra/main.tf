
locals {
  company              = "epam"
  normalized_workspace = terraform.workspace == "default" ? "dev" : lower(terraform.workspace)
  name_prefix          = "${local.company}-${local.normalized_workspace}"
  resource_group_name  = "${local.name_prefix}-rg"
}

resource "azurerm_resource_group" "epam-rg" {
  name     = local.resource_group_name
  location = var.location
  tags = {
    Workspace = local.normalized_workspace
  }
}

module "state-storage" {
  source               = "./modules/state-storage"
  location             = var.location
  normalized_workspace = local.normalized_workspace
}

module "network" {
  source               = "./modules/network"
  resource_group_name  = local.resource_group_name
  location             = var.location
  env_prefix           = local.name_prefix
  normalized_workspace = local.normalized_workspace
}

module "mysql-database" {
  source               = "./modules/mysql-database"
  resource_group_name  = local.resource_group_name
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
  resource_group_name        = local.resource_group_name
  virtual_network_id         = module.network.virtual_network_id
  backend_subnet_id          = module.network.backend_subnet_id
  mysql_flexible_server_fqdn = module.mysql-database.mysql_flexible_server_fqdn
  admin_username             = var.admin_username
}



module "monitoring" {
  source              = "./modules/monitoring"
  location            = var.location
  resource_group_name = local.resource_group_name
  lb_id               = module.load-balancer.lb_id
  env_prefix          = local.name_prefix
}

module "app-service" {
  source               = "./modules/app-service"
  resource_group_name  = local.resource_group_name
  lb_public_ip         = module.load-balancer.lb_id
  env_prefix           = local.name_prefix
  app_name             = "movies"
  normalized_workspace = local.normalized_workspace
  location             = var.location
}
