provider "azurerm" {
  features {}
}

module "aks_westeurope" {
  source = "../modules/aks_cluster"

  resource_group_name                =  var.resource_group_name
  location                           =  var.location
  aks_cluster_name                   =  var.aks_cluster_name
  node_pool_name                     =  var.node_pool_name
  node_size                          =  var.node_size
  node_count                         =  var.node_count
  tenant_id                          = var.tenant_id
  role_based_access_control_enabled  =  var.role_based_access_control_enabled
  environment                        = var.environment
  kubernetes_version                 = var.kubernetes_version
  azure_rbac_enabled                 = var.azure_rbac_enabled
}
