
locals {
  normalized_workspace = terraform.workspace == "default" ? "dev" : lower(terraform.workspace)
  name_prefix          = "epamtfstate${substr(local.normalized_workspace, 0, 4)}"
  location             = var.location
}

resource "azurerm_resource_group" "state" {
  name     = "epam${local.name_prefix}-rg"
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
