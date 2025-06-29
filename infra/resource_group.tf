# resource "azurerm_resource_group" "main" {
#   name     = "rg-${local.env_suffix}-core"
#   location = var.location

#   tags = {
#     Environment = local.env_suffix
#   }
# }
