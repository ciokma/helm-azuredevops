output "aks_cluster_name" {
  description = "The name of the AKS cluster."
  value       = module.aks.aks_cluster_name
}

output "aks_kubeconfig" {
  description = "The Kubernetes configuration to connect to the AKS cluster."
  value       = module.aks.kubeconfig
  sensitive   = true # Esto evita que el contenido se muestre en la consola
}
