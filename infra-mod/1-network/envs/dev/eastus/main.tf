
module "vnet" {
  source              = "../../../../modules/vnet/v1.0"
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space

  aks_subnet_name   = var.aks_subnet_name
  aks_subnet_prefix = var.aks_subnet_prefix

  function_subnet_name    = var.function_subnet_name
  function_subnet_prefix  = var.function_subnet_prefix
  deploy_function_in_vnet = var.deploy_function_in_vnet
}
