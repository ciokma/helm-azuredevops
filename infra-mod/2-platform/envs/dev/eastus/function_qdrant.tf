data "terraform_remote_state" "bootstrap" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-tfstates"
    storage_account_name = "sttfstateusdev"
    container_name       = "tfstate"
    key                  = "bootstrap.terraform.tfstate"
  }
}
module "function_qdrant_backup" {
  source                     = "/mnt/d/Terraform/helm-azuredevops/infra-mod/modules/function_qdrant_backup/v1.0"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  function_name              = var.function_name
  aks_cluster_name           = local.aks_cluster_name
  target_resource_group_name = var.target_resource_group_name
  tenant_id                  = var.tenant_id
  subscription_id            = var.subscription_id
  environment                = var.environment
  function_vnet_subnet_id    = data.terraform_remote_state.network.outputs.function_subnet_id

  # New: Pass the AKS cluster ID to the function module
  aks_id                   = module.aks.aks_id
  resource_group_id        = data.terraform_remote_state.bootstrap.outputs.resource_group_id
  target_resource_group_id = data.terraform_remote_state.bootstrap.outputs.target_resource_group_id
  create_in_vnet           = var.create_in_vnet
  qdrant_pv_pattern        = var.qdrant_pv_pattern
  qdrant_namespace         = var.qdrant_namespace
  aks_audience             = var.aks_audience
}

