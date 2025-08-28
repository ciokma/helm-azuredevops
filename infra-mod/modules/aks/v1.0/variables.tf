variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "aks_cluster_name" { type = string }
variable "node_size" { type = string }
variable "node_count" { type = number }
variable "node_pool_name" { type = string }

variable "tenant_id" { type = string }
variable "admin_group_object_ids" { type = list(string) }
variable "azure_rbac_enabled" { type = bool }
variable "kubernetes_version" { type = string }

variable "private_cluster_enabled" {
  description = "If true, enable private AKS cluster"
  type        = bool
  default     = true
}

variable "private_cluster_public_fqdn_enabled" {
  type    = bool
  default = false
}

variable "aks_subnet_id" { type = string }

variable "service_cidr" { type = string }
variable "dns_service_ip" { type = string }
variable "environment" { type = string }
