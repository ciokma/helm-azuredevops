# Role Assignment para Cluster User
resource "azurerm_role_assignment" "function_cluster_user" {
  scope                = azurerm_kubernetes_cluster.k8s.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azurerm_user_assigned_identity.function_identity.principal_id
}

# Role Assignment para Cluster Admin
resource "azurerm_role_assignment" "function_cluster_admin" {
  scope                = azurerm_kubernetes_cluster.k8s.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azurerm_user_assigned_identity.function_identity.principal_id
}

resource "azurerm_role_assignment" "function_contributor_rg" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.function_identity.principal_id
}
# Rol de lectura de blobs para la Function
resource "azurerm_role_assignment" "function_storage_blob_reader" {
  scope                = azurerm_storage_account.function_sa.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.function_identity.principal_id
}

# luego cambiar
# Role Assignment para permitir a la función crear snapshots
resource "azurerm_role_assignment" "function_snapshot_contributor" {
  # El scope debe ser el grupo de recursos donde se crearan los snapshots.
  # El error indica que es "rg-qdrant-snapshot-pv".
  scope                = "/subscriptions/f9703f5b-83a3-4d1e-9872-e4b59e50de6e/resourceGroups/rg-qdrant-snapshot-pv"
  
  # El rol de Contributor permite la escritura de snapshots.
  role_definition_name = "Contributor"
  
  # La principal es la identidad gestionada de tu función.
  principal_id         = azurerm_user_assigned_identity.function_identity.principal_id
}