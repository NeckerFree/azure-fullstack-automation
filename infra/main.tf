
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

data "http" "myip" {
  url = "https://ifconfig.me/ip"
}

resource "azurerm_resource_group" "epam-rg" {
  name     = local.resource_group_name
  location = var.location
  tags = {
    Workspace = local.environment
  }
}

module "network" {
  source                         = "./modules/network"
  resource_group_name            = azurerm_resource_group.epam-rg.name
  location                       = azurerm_resource_group.epam-rg.location
  env_prefix                     = local.name_prefix
  environment                    = local.environment
  bastion_public_ip              = module.load-balancer.control_node_public_ip
  allowed_ssh_ip                 = var.allowed_ssh_ip
  network_interface_control_id   = module.load-balancer.network_interface_control_id
  jumpbox_private_ip             = module.load-balancer.network_interface_control_private_ip
  network_interface_backend_0_id = module.load-balancer.network_interface_backend_0_id
  network_interface_backend_1_id = module.load-balancer.network_interface_backend_1_id

}

module "mysql-database" {
  source                      = "./modules/mysql-database"
  resource_group_name         = azurerm_resource_group.epam-rg.name
  location                    = azurerm_resource_group.epam-rg.location
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
  resource_group_name     = azurerm_resource_group.epam-rg.name
  location                = azurerm_resource_group.epam-rg.location
  env_prefix              = local.name_prefix
  environment             = local.environment
  virtual_network_main_id = module.network.virtual_network_main_id
  backend_subnet_id       = module.network.backend_subnet_id
  mysql_fqdn              = module.mysql-database.mysql_fqdn
  admin_username          = var.admin_username
}



module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = azurerm_resource_group.epam-rg.name
  location            = azurerm_resource_group.epam-rg.location
  lb_id               = module.load-balancer.lb_id
  env_prefix          = local.name_prefix
}

module "app-service" {
  source              = "./modules/app-service"
  resource_group_name = azurerm_resource_group.epam-rg.name
  location            = azurerm_resource_group.epam-rg.location
  lb_public_ip        = module.load-balancer.lb_id
  env_prefix          = local.name_prefix
  app_name            = "movies"
  environment         = local.environment
}

output "mysql_fqdn" {
  value = module.mysql-database.mysql_fqdn
}

output "mysql_admin_user" {
  value     = module.mysql-database.mysql_admin_user
  sensitive = true
}

output "mysql_admin_pwd" {
  value     = module.mysql-database.mysql_admin_pwd
  sensitive = true
}

output "mysql_database_name" {
  value = module.mysql-database.mysql_database_name
}

output "lb_api_url" {
  value = module.load-balancer.lb_api_url
}
