variable "resource_group_name" {
  type        = string
  default     = "rg-dev"
}

variable "location" {
  type        = string
  default     = "eastus"
}

variable "vnet_name" {
  type        = string
  default     = "vnet-aks"
}

variable "vnet_address_space" {
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "aks_subnet_name" {
  type        = string
  default     = "subnet-aks"
}

variable "aks_subnet_prefix" {
  type        = string
  default     = "10.10.1.0/24"
}

variable "function_subnet_name" {
  type        = string
  default     = "subnet-func"
}

variable "function_subnet_prefix" {
  type        = string
  default     = "10.10.2.0/24"
}

variable "deploy_function_in_vnet" {
  type        = bool
  default     = true
}
variable "subscription_id" {
  type = string
}
variable "tenant_id" {
  type = string
}
