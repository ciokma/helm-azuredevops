output "vnet_id" {
  value       = module.vnet.vnet_id
  description = "The ID of the Virtual Network created by this module."
}
output "aks_subnet_id" {
  description = "The ID of the AKS subnet."
  value       = module.vnet.aks_subnet_id
}
output "function_subnet_id" {
  description = "The ID of the Azure Function App subnet."
  value       = module.vnet.function_subnet_id
}