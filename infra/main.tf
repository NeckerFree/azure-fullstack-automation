
locals {
  company     = "soft"
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

# data "http" "myip" {
#   url = "https://ifconfig.me/ip"
# }

resource "azurerm_resource_group" "soft-rg" {
  name     = local.resource_group_name
  location = var.location
  tags = {
    Workspace = local.environment
  }
}

module "network" {
  source                                      = "./modules/network"
  resource_group_name                         = azurerm_resource_group.soft-rg.name
  location                                    = azurerm_resource_group.soft-rg.location
  env_prefix                                  = local.name_prefix
  environment                                 = local.environment
  bastion_public_ip                           = module.load-balancer.control_node_public_ip
  allowed_ssh_ip                              = var.allowed_ssh_ip
  network_interface_control_id                = module.load-balancer.network_interface_control_id
  jumpbox_private_ip                          = module.load-balancer.network_interface_control_private_ip
  network_interface_backend_0_id              = module.load-balancer.network_interface_backend_0_id
  network_interface_backend_1_id              = module.load-balancer.network_interface_backend_1_id
  azurerm_lb_backend_address_pool_api_pool_id = module.load-balancer.azurerm_lb_backend_address_pool_api_pool_id

}

module "mysql-database" {
  source                      = "./modules/mysql-database"
  resource_group_name         = azurerm_resource_group.soft-rg.name
  location                    = azurerm_resource_group.soft-rg.location
  env_prefix                  = local.name_prefix
  environment                 = local.environment
  mysql_user                  = var.mysql_user
  mysql_admin_password        = var.mysql_admin_password
  subnet_db_id                = module.network.db_subnet_id
  private_dns_zone_mysql_id   = module.load-balancer.private_dns_zone_mysql_id
  private_dns_zone_mysql_name = module.load-balancer.private_dns_zone_mysql_name
  virtual_network_main_id     = module.network.virtual_network_main_id
}

module "load-balancer" {
  source                  = "./modules/load-balancer"
  resource_group_name     = azurerm_resource_group.soft-rg.name
  location                = azurerm_resource_group.soft-rg.location
  env_prefix              = local.name_prefix
  environment             = local.environment
  virtual_network_main_id = module.network.virtual_network_main_id
  backend_subnet_id       = module.network.backend_subnet_id
  mysql_fqdn              = module.mysql-database.mysql_fqdn
  admin_username          = var.admin_username
  ssh_public_key          = var.ssh_public_key
  lb_dns_name             = var.lb_dns_name
}



module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = azurerm_resource_group.soft-rg.name
  location            = azurerm_resource_group.soft-rg.location
  lb_id               = module.load-balancer.lb_id
  env_prefix          = local.name_prefix
}

module "app-service" {
  source              = "./modules/app-service"
  resource_group_name = azurerm_resource_group.soft-rg.name
  location            = azurerm_resource_group.soft-rg.location
  lb_public_ip        = module.load-balancer.lb_id
  env_prefix          = local.name_prefix
  app_name            = "movies"
  environment         = local.environment
}


