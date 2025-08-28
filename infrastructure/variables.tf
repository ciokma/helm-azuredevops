variable "resource_group_name" {
  default = "rg-dev"
}
variable "tg_resource_group_name" {
  default = "rg-qdrant-snapshot-pv"
}

variable "location" {
  default = "eastus"
}

variable "aks_cluster_name" {
  default = "aks-test-cluster"
}

variable "node_size" {
  default = "Standard_B2s" # $0.02–$0.05 USD por hora Standard_B1s
}

variable "node_count" {
  default = 1
}
variable "node_pool_name" {
  type        = string
  description = "the user node pool name(for k8s workloas other than system)"
  default     = "aksnodepool"
}

# vars
variable "aks_admins_group_id" {
  type        = string
  description = "Object ID del grupo aks-admins"
}

variable "aks_dev_users_group_id" {
  type        = string
  description = "Object ID del grupo aks-dev-users"
}

variable "aks_readonly_users_group_id" {
  type        = string
  description = "Object ID del grupo aks-readonly-users"
}

variable "aks_readonly_higher_group_id" {
  type        = string
  description = "Object ID del grupo aks-readonly-higher-users"
}

variable "dev_namespaces" {
  type        = list(string)
  description = "Namespaces where development users will have admin permissions"
  default     = ["ns1", "ns2", "ns3", "ns4", "ns5", "ns6", "ns7", "ns8", "ns9", "ns10", "ns11", "ns12"]
}
variable "readonly_namespaces" {
  type        = list(string)
  description = "Namespaces where readonly users will have read-only access"
  default     = ["ns1", "ns2", "ns3", "ns4", "ns5", "ns6", "ns7", "ns8", "ns9", "ns10", "ns11", "ns12", ]
}
variable "subscription_id" {
  type = string
}
variable "tenant_id" {
  type = string
}
variable "role_based_access_control_enabled" {
  type = string
}
variable "admin_group_object_id" {
  description = "Azure AD group object ID to grant cluster-admin access"
}

variable "azure_rbac_enabled" {
  description = "azure rbac enable or not"
}
variable "kubernetes_version" {
  description = "kubernetes version"
}

variable "azure_client_secret" {
  description = "client secret"
}
variable "environment" {
  description = "environment"
}
variable "qdrant_target_rg" {
  description = "qdrant snapshot target resource group"

}