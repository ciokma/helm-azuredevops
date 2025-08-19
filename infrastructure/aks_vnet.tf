# Define la red virtual con un CIDR válido.
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-aks"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Define la subred para los nodos de AKS, asegurando que esté dentro del espacio de direcciones de la VNet.
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-aks"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.10.1.0/24"]
}
