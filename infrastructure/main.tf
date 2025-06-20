resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "k8s-${var.aks_cluster_name}"

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
