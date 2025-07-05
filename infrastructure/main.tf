provider "azurerm" {
  features        {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

module "aks_us" {
  source = "./modules/aks_cluster"

  resource_group_name               = "rg-dev-eastus"
  location                          = "eastus"
  aks_cluster_name                  = "aks-us-cluster"
  node_pool_name                    = "usapps"
  node_size                         = "Standard_B2s"
  node_count                        = 1
  tenant_id                         = var.tenant_id
  role_based_access_control_enabled = true
  environment                       = "Test"
  kubernetes_version                = "1.32.4"
  azure_rbac_enabled                = var.azure_rbac_enabled
}

module "aks_eu" {
  source = "./modules/aks_cluster"

  resource_group_name               = "rg-dev-westeurope"
  location                          = "westeurope"
  aks_cluster_name                  = "aks-eu-cluster"
  node_pool_name                    = "euapps"
  node_size                         = "Standard_B2s"
  node_count                        = 1
  tenant_id                         = var.tenant_id
  role_based_access_control_enabled = true
  environment                       = "Test"
  kubernetes_version                = "1.32.4"
  azure_rbac_enabled                = var.azure_rbac_enabled
}
