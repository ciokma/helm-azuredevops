variable "client_name" {
  default     = "aks"
  type        = string
  description = "aks client name"
}

variable "location" {
  description = "Azure region where the AKS cluster will be deployed"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the Resource Group where AKS will be deployed"
  type        = string
  default     = "rg-qdrant-snapshot-pv"
}


variable "kubernetes_version" {
  description = "Kubernetes version to deploy"
  type        = string
  default     = "1.32.5"
}

variable "role_based_access_control_enabled" {
  description = "Enable RBAC for the AKS cluster"
  type        = bool
  default     = true
}

variable "tenant_id" {
  description = "Azure Tenant ID for AAD integration"
  type        = string
}

variable "admin_group_object_ids" {
  description = "List of Object IDs for admin groups in Azure AD"
  type        = list(string)
}


variable "service_cidr" {
  description = "CIDR range for Kubernetes services"
  type        = string
  default     = "10.200.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP for Kubernetes"
  type        = string
  default     = "10.200.0.10"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size for the nodes"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "tags" {
  description = "Tags to apply to the AKS cluster"
  type        = map(string)
  default = {
    Environment = "dev"
  }
}



variable "node_size" {
  default = "Standard_B2s"
}



variable "node_pool_name" {
  default     = "aksnodepool"
  description = "User node pool name for workloads"
}

variable "subscription_id" {
  type = string
}

variable "azure_rbac_enabled" {
  description = "Enable Azure RBAC"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Deployment environment"
  default     = "dev"
}

# --- AKS Network ---


variable "function_subnet_id" {
  description = "ID of the subnet for Azure Function"
  default     = null
}

variable "deploy_function_in_vnet" {
  type        = bool
  description = "Deploy Azure Function in VNet"
  default     = true
}

# --- Function ---
variable "function_name" {
  default = "func-aks-backup"
}

variable "target_resource_group_name" {
  default = "rg-qdrant-snapshot-pv"
}
variable "aks_admins_group_id" {

}
variable "private_cluster_enabled" {

}
variable "private_cluster_public_fqdn_enabled" {

}
variable "create_in_vnet" {

}
variable "qdrant_pv_pattern" {

}
variable "qdrant_namespace" {

}
variable "aks_audience" {

}
variable "alert_email_address" {
  description = "The email address to receive function failure alerts."
  type        = string
}
variable "cron_schedule" {

}