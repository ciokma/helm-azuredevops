resource "azurerm_resource_group" "tg-rg" {
  name     = var.tg_resource_group_name
  location = var.location
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Configura el clúster de Kubernetes (AKS).
resource "azurerm_kubernetes_cluster" "k8s" {
  name                         = var.aks_cluster_name
  location                     = var.location
  resource_group_name          = azurerm_resource_group.rg.name
  dns_prefix                   = "k8s-${var.aks_cluster_name}"
  kubernetes_version           = var.kubernetes_version

  # Configuración para hacer el cluster privado
  private_cluster_enabled          = true
  private_cluster_public_fqdn_enabled = false

  # Habilita el control de acceso basado en roles (RBAC)
  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    tenant_id          = var.tenant_id
    admin_group_object_ids = var.admin_group_object_id
    azure_rbac_enabled = false
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
    # Define el rango de IP para los servicios de Kubernetes,
    # asegurando que no se solape con la VNet o sus subredes.
    service_cidr = "10.200.0.0/16"
    # Se agrega la dirección IP del servicio DNS, que debe estar dentro del service_cidr.
    dns_service_ip = "10.200.0.10"
  }

  default_node_pool {
    name                 = "default"
    node_count           = var.node_count
    vm_size              = var.node_size
    only_critical_addons_enabled = true
    # Conecta la pool de nodos a la subred de la VNet
    vnet_subnet_id = azurerm_subnet.subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Test"
  }
}
