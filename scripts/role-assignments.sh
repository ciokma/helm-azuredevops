az role assignment create \
  --assignee 74ce25d5-8dd4-498d-85a5-1af8c4cbd70e \
  --role Contributor \
  --scope /subscriptions/f9703f5b-83a3-4d1e-9872-e4b59e50de6e/resourceGroups/rg-qdrant-snapshot


  az role assignment create \
  --assignee 74ce25d5-8dd4-498d-85a5-1af8c4cbd70e \
  --role Contributor \
  --scope /subscriptions/f9703f5b-83a3-4d1e-9872-e4b59e50de6e


az group create \
  --name rg-qdrant-snapshot-pv \
  --location eastus

# privado
az role assignment create \
  --assignee "74ce25d5-8dd4-498d-85a5-1af8c4cbd70e" \
  --role "Contributor" \
  --scope "/subscriptions/f9703f5b-83a3-4d1e-9872-e4b59e50de6e/resourceGroups/rg-dev"

az role assignment create \
  --assignee "74ce25d5-8dd4-498d-85a5-1af8c4cbd70e" \
  --role "Azure Kubernetes Service RBAC Cluster Admin" \
  --scope "/subscriptions/f9703f5b-83a3-4d1e-9872-e4b59e50de6e/resourceGroups/rg-dev/providers/Microsoft.ContainerService/managedClusters/aks-dev"