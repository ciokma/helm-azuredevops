
data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "stgaccounttf"
    container_name       = "tfstate"
    key                  = "1-network.tfstate" # El nombre de estado del módulo 1
  }
}
module "aks" {
  source                    = "../../../../modules/aks/v1.0"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  aks_cluster_name          = local.aks_cluster_name
  node_size                 = var.node_size
  node_count                = var.node_count
  node_pool_name            = var.node_pool_name

  tenant_id                 = var.tenant_id
  admin_group_object_id     = [var.admin_group_object_id]
  azure_rbac_enabled        = var.azure_rbac_enabled
  kubernetes_version        = var.kubernetes_version

  private_cluster_enabled             = var.private_cluster_enabled
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled

  aks_subnet_id             = data.terraform_remote_state.network.outputs.aks_subnet_id
  service_cidr              = var.service_cidr
  dns_service_ip            = var.dns_service_ip
  environment               = var.environment
}
