variable "subscription_id" {}
variable "tenant_id" {}
variable "azure_rbac_enabled" {
  type = string
}
variable "name_proxy_db_username" {
  default = "user"
}
variable "location" {
  default = "mexicocentral"
}
variable  "resource_group_name" {
  default = "rg-dev-eastus"
}

