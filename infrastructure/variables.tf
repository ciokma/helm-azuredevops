variable "resource_group_name" {
  default = "aks-us-test-rg"
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
    type = string
    description = "the user node pool name(for k8s workloas other than system)"  
    default = "aksnodepool"
}