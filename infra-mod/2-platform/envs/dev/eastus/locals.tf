locals {
  # Short region code
  azure_region = {
    location_short = "eastus"
  }

  # AKS cluster name dynamically generated
  aks_cluster_name = "aks-platform-${var.client_name}-${local.azure_region.location_short}-${var.environment}"

  # Optional: DNS prefix based on environment
  aks_dns_prefix = "${var.environment}-aks"

  # Azure Function name dynamically generated based on cluster and env
  function_qdrant_name = "qdrant-backup-${var.client_name}-${local.azure_region.location_short}-${var.environment}"
}
