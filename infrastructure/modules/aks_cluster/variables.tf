variable "resource_group_name" {}
variable "location" {}
variable "aks_cluster_name" {}
variable "node_pool_name" {}
variable "node_size" {}
variable "node_count" {}
variable "role_based_access_control_enabled" { default = true }
variable "tenant_id" {}
variable "environment" { default = "Test" }
variable "kubernetes_version" { default = "1.32.4" }
variable "azure_rbac_enabled" {
  type = string
}