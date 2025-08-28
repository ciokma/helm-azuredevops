output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}

output "kube_admin_config" {
  value     = azurerm_kubernetes_cluster.k8s.kube_admin_config_raw
  sensitive = true
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.k8s.id
}
output "aks_cluster_name" {
  description = "The name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.k8s.name
}

