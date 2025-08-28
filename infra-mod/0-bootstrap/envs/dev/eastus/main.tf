
resource "azurerm_resource_group" "resource_group_name" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_resource_group" "target_resource_group_name" {
  name     = var.target_resource_group_name
  location = var.location
}