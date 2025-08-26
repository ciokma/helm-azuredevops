resource "azurerm_kubernetes_cluster_node_pool" "user_pool" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  name                  = var.node_pool_name
  vm_size               = var.node_size
  mode                  = "User"
  node_count            = var.node_count
  tags                  = { Environment = "Test", Worker = "true" }
  node_taints           = ["node-role.kubernetes.io/workload=apps:NoSchedule"]
  #node_taints = [ "node-role.kubernetes.io/workload=apps:PreferNoSchedule" ]
  upgrade_settings {
    drain_timeout_in_minutes      = 0
    node_soak_duration_in_minutes = 0
    max_surge                     = "40%"
  }
  # Requerido cuando cambias propiedades que fuerzan rotación
  temporary_name_for_rotation = "userpooltemp"
  lifecycle {
    ignore_changes = [
      node_count,
      tags,
      node_taints,
      upgrade_settings,
      temporary_name_for_rotation
    ]
  }
}