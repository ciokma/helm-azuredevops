resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "k8s-${var.aks_cluster_name}"
  kubernetes_version  = var.kubernetes_version

  private_cluster_enabled             = var.private_cluster_enabled
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    tenant_id              = var.tenant_id
    admin_group_object_ids = var.admin_group_object_id
    azure_rbac_enabled     = var.azure_rbac_enabled
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
  }

  default_node_pool {
    name                         = "default"
    node_count                   = var.node_count
    vm_size                      = var.node_size
    only_critical_addons_enabled = true
    vnet_subnet_id               = var.aks_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [default_node_pool]
  }
}

module "user_node_pool" {
  source              = "./user_node_pool.tf"
}
