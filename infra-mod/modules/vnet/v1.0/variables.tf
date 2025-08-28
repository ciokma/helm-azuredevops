variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vnet_name" { type = string }
variable "vnet_address_space" { type = list(string) }

variable "aks_subnet_name" { type = string }
variable "aks_subnet_prefix" { type = string }

variable "function_subnet_name" { type = string }
variable "function_subnet_prefix" { type = string }
variable "deploy_function_in_vnet" {
  description = "If true, deploy subnet for function integration"
  type        = bool
  default     = true
}
