# Role Assignment for the Function Identity to read the AKS cluster
resource "azurerm_role_assignment" "function_reader_aks_cluster" {
  # The scope is the ID of the AKS cluster.
  scope = var.aks_id
  # The Reader role is required to read cluster details.
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  # The principal is your function's managed identity.
  principal_id = azurerm_user_assigned_identity.function_identity.principal_id
}

# Role Assignment para Cluster Admin
resource "azurerm_role_assignment" "function_cluster_admin" {
  scope                = var.aks_id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azurerm_user_assigned_identity.function_identity.principal_id
}

resource "azurerm_role_assignment" "function_contributor_rg" {
  scope                = var.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.function_identity.principal_id
}
# Rol de lectura de blobs para la Function
resource "azurerm_role_assignment" "function_storage_blob_reader" {
  scope                = azurerm_storage_account.function_sa.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.function_identity.principal_id
}
# Role Assignment to allow the function to create snapshots
resource "azurerm_role_assignment" "function_snapshot_contributor" {
  # Referencing the ID of the target resource group
  scope = var.target_resource_group_id
  # The Contributor role allows snapshot creation
  role_definition_name = "Contributor"
  # The principal is your function's managed identity
  principal_id = azurerm_user_assigned_identity.function_identity.principal_id
}