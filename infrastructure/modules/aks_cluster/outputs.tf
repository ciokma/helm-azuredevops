output "kube_config" {
  value = azurerm_kubernetes_cluster.k8s.kube_config[0]
}

output "kube_admin_config" {
  value = azurerm_kubernetes_cluster.k8s.kube_admin_config[0]
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.k8s.id
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
