output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks_subnet.id
}

output "function_subnet_id" {
  value = try(azurerm_subnet.function_subnet[0].id, null)
}
