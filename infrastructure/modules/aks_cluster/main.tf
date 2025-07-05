resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "k8s-${var.aks_cluster_name}"

  kubernetes_version = var.kubernetes_version

  role_based_access_control_enabled = var.role_based_access_control_enabled

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = var.azure_rbac_enabled
    tenant_id          = var.tenant_id
  }

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_size

    only_critical_addons_enabled = true

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "40%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user_pool" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  name                  = var.node_pool_name
  vm_size               = var.node_size
  mode                  = "User"
  node_count            = var.node_count
  node_taints           = ["node-role.kubernetes.io/workload=apps:NoSchedule"]

  upgrade_settings {
    drain_timeout_in_minutes      = 0
    node_soak_duration_in_minutes = 0
    max_surge                     = "40%"
  }

  tags = {
    Environment = var.environment
    Worker      = "true"
  }
}
