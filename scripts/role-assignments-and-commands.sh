az role assignment create \
  --assignee 74ce25d5-8dd4-498d-85a5-1af8c4cbd70e \
  --role Contributor \
  --scope /subscriptions/f9703f5b-83a3-4d1e-9872-e4b59e50de6e/resourceGroups/rg-qdrant-snapshot-pv


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


 az group exists --name rg-qdrant-snapshot-pv | grep -q true

 az aks command invoke \
  --resource-group "rg-dev" \
  --name "aks-dev" \
  --command "kubectl apply -f -" \
  --file "sts.yaml"

  # crear recurso en private cluster
  az aks command invoke \
  --resource-group "rg-dev" \
  --name "aks-dev" \
  --command "kubectl apply -f sts.yaml" \
  --file "sts.yaml"

    az aks command invoke \
  --resource-group "rg-dev" \
  --name "aks-dev" \
  --command "kubectl get pv" 

# get pv
   az aks command invoke \
        --resource-group rg-dev \
        --name aks-dev \
        --command "kubectl get pv -n default -o json" | jq --arg search "qdrant" '.items[] | select(.spec.claimRef.name | contains($search)) | select(.spec.claimRef.namespace=="default")'

result=$(az aks command invoke \
  --resource-group "rg-dev" \
  --name "aks-dev" \
  --command "kubectl get pv -n default -o json")

echo "$result" | sed '1,2d' | jq \
  --arg search "qdrant" \
  '.items[] | select(.spec.claimRef.name | contains($search)) | select(.spec.claimRef.namespace=="default")'


  # Usa az aks command invoke y pasa directamente el comando kubectl y el archivo JSON
az aks command invoke \
  --resource-group "rg-dev" \
  --name "$cluster_name" \
  --command "kubectl get pv -n default -o json" | \
  jq \
  --arg search "$search_claim" \
  '.items[] | select(.spec.claimRef.name | contains($search)) | select(.spec.claimRef.namespace=="default")'


  az aks command invoke \
  --resource-group "rg-dev" \
  --name "aks-dev" \
  --command "kubectl get pv -n default -o json" | \
  jq \
  --arg search "qrant" \
  '.items[] | select(.spec.claimRef.name | contains($search)) | select(.spec.claimRef.namespace=="default")'

  
  ## bueno
  az aks command invoke   --resource-group "rg-dev"   --name "aks-dev"   --command "kubectl get pv -n default -o json" --query "logs" -o tsv

   result=$(az aks command invoke \
    --resource-group "rg-dev" \
    --name "aks-dev" \
    --command "kubectl get pv -n default -o json" \
    --query "logs" -o tsv)

   echo "$result" | jq \
    --arg search "$search_claim" \
    '.items[] | select(.spec.claimRef.name | contains($search)) | select(.spec.claimRef.namespace=="default")'

    ## applicationID
    #maurez89-devops-tests-7cfed03d-d6a6-4284-89b7-ff191d896c79
# 74ce25d5-8dd4-498d-85a5-1af8c4cbd70e
# 8/18/2025

#suscription
#f9703f5b-83a3-4d1e-9872-e4b59e50de6e