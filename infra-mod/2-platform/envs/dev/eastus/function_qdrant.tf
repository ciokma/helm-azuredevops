  data "terraform_remote_state" "network" {
    backend = "azurerm"
    config = {
      resource_group_name  = "rg-tfstate"
      storage_account_name = "stgaccounttf"
      container_name       = "tfstate"
      key                  = "1-network.tfstate"
    }
  }

  module "function_qdrant_backup" {
    source                   = "../../../modules/function_qdrant_backup/v1.0"
    resource_group_name      = var.resource_group_name
    location                 = var.location
    function_name            = var.function_name
    aks_cluster_name         = local.aks_cluster_name
    tg_resource_group_name   = var.target_resource_group_name
    tenant_id                = var.tenant_id
    subscription_id          = var.subscription_id
    environment              = var.environment
    function_vnet_subnet_id  = data.terraform_remote_state.network.outputs.function_subnet_id
  }

