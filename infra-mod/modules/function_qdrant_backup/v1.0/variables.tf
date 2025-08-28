variable "function_name" {}
variable "resource_group_name" {}
variable "location" {}
variable "subnet_id" {
  description = "Subnet ID for VNet deployment (only if deploy_in_vnet = true)"
  default     = ""
}
variable "deploy_in_vnet" {
  description = "Whether to deploy the function inside a VNet"
  type        = bool
  default     = false
}

variable "aks_cluster_name" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "target_resource_group_name" {}
variable "environment" {}
# Whether to deploy the function inside a VNet
variable "create_in_vnet" {
  description = "If true, deploy the Azure Function inside a VNet"
  type        = bool
  default     = false
}
variable "function_vnet_subnet_id" {
  description = "The ID of the VNet subnet for the Function App."
  type        = string
  default     = null # Permite que sea opcional si no se va a desplegar en VNet
}