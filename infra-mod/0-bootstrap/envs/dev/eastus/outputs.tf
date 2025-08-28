output "resource_group_name" {
  description = "The name of the main resource group."
  value       = azurerm_resource_group.resource_group_name.name
}
output "target_resource_group_name" {
  description = "The name of the target resource group."
  value       = azurerm_resource_group.target_resource_group_name.name
}