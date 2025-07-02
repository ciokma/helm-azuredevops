resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "k8s-${var.aks_cluster_name}"
  # Activa Azure RBAC para el API server de Kubernetes.
  # Permite controlar el acceso desde Azure, 
  # en lugar de usar archivos RoleBinding/ClusterRoleBinding tradicionales en YAML.
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true # (Optional) 
    admin_group_object_ids = [
    "de8d606b-8869-4433-8be0-8bf4703ec810" # ID de grupo de admins
    ]
    managed = true
    #tenant_id = ( optional )
  }
  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_size
    #others
    only_critical_addons_enabled = true
    upgrade_settings {
      drain_timeout_in_minutes = 0
      max_surge = "40%"
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
