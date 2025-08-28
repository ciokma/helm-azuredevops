output "resource_group_name" {
  description = "The name of the main resource group."
  value       = azurerm_resource_group.resource_group_name.name
}
output "target_resource_group_name" {
  description = "The name of the target resource group."
  value       = azurerm_resource_group.target_resource_group_name.name
}
output "resource_group_id" {
  description = "The ID of the main resource group."
  value       = azurerm_resource_group.resource_group_name.id
}

output "target_resource_group_id" {
  description = "The ID of the target resource group for snapshots."
  value       = azurerm_resource_group.target_resource_group_name.id
}