
locals {
  company     = "epam"
  environment = lower(terraform.workspace)
  name_prefix = "${local.company}${local.environment}"

  env_map = {
    default = "dev"
    qa      = "qa"
    staging = "staging"
    prod    = "prod"
  }
  environment_final = lookup(local.env_map, terraform.workspace, "dev")

  resource_group_name     = "${local.company}${local.environment_final}rg"
  tfstate_storage_account = "${replace(local.environment_final, "-", "")}tfstate"
}

resource "azurerm_resource_group" "epam-rg" {
  name     = "epamqarg"
  location = var.location
  tags = {
    Workspace = local.environment
  }
}

module "network" {
  source              = "./modules/network"
  resource_group_name = "epamqarg"
  location            = var.location
  env_prefix          = local.name_prefix
  environment         = local.environment
  depends_on          = [azurerm_resource_group.epam-rg]
}

module "mysql-database" {
  source               = "./modules/mysql-database"
  resource_group_name  = "epamqarg"
  location             = var.location
  env_prefix           = local.name_prefix
  subnet_id            = module.network.db_subnet_id
  environment          = local.environment
  mysql_user           = var.mysql_user
  mysql_admin_password = var.mysql_admin_password
}

module "load-balancer" {
  source              = "./modules/load-balancer"
  location            = var.location
  env_prefix          = local.name_prefix
  environment         = local.environment
  resource_group_name = "epamqarg"
  virtual_network_id  = module.network.virtual_network_id
  backend_subnet_id   = module.network.backend_subnet_id
  mysql_fqdn          = module.mysql-database.mysql_fqdn
  admin_username      = var.admin_username
}



module "monitoring" {
  source              = "./modules/monitoring"
  location            = var.location
  resource_group_name = "epamqarg"
  lb_id               = module.load-balancer.lb_id
  env_prefix          = local.name_prefix
}

module "app-service" {
  source              = "./modules/app-service"
  resource_group_name = "epamqarg"
  lb_public_ip        = module.load-balancer.lb_id
  env_prefix          = local.name_prefix
  app_name            = "movies"
  environment         = local.environment
  location            = var.location
}
