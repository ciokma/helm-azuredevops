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
  # enable RBAC
  role_based_access_control_enabled = true
  
  azure_active_directory_role_based_access_control {
    tenant_id              = var.tenant_id
    admin_group_object_ids = [var.admin_group_object_id]
    azure_rbac_enabled = false
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
    Environment = "Test"
  }
}
