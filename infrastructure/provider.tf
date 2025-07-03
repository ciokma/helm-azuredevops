provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.26.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "=2.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=2.36.0"
    }
  }

  required_version = ">= 1.4.0"
}
# provider "kubernetes" {
#   host                   = azurerm_kubernetes_cluster.k8s.kube_config[0].host
#   client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
#   client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
#   cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
# }