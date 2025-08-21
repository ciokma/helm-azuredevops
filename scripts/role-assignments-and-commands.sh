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

    # dar permiso al cluster a la service connection de azdo
    az role assignment create \
  --assignee 74ce25d5-8dd4-498d-85a5-1af8c4cbd70e \
  --role "Azure Kubernetes Service RBAC Cluster Admin" \
  --scope /subscriptions/f9703f5b-83a3-4d1e-9872-e4b59e50de6e/resourceGroups/rg-dev/providers/Microsoft.ContainerService/managedClusters/aks-dev
# Application (client) ID
# 74ce25d5-8dd4-498d-85a5-1af8c4cbd70e

# dar permiso a todo
    az role assignment create \
  --assignee 74ce25d5-8dd4-498d-85a5-1af8c4cbd70e \
  --role "Azure Kubernetes Service RBAC Cluster Admin" \
  --scope /subscriptions/f9703f5b-83a3-4d1e-9872-e4b59e50de6e




az ad sp show --id 74ce25d5-8dd4-498d-85a5-1af8c4cbd70e --query objectId -o tsv

 az aks command invoke \
  --resource-group "rg-dev" \
  --name "aks-dev" \
  --command "kubectl apply -f -" \
  --file "crb-spn.yaml"

    # crear recurso en private cluster
  az aks command invoke \
  --resource-group "rg-dev" \
  --name "aks-dev" \
  --command "kubectl apply -f crb-spn.yaml" \
  --file "crb-spn.yaml"


#bueno para copiar
base64 qdrant_volume_snapshot.sh > qdrant_volume_snapshot.sh.b64

  az container exec \
  --resource-group rg-qdrant-snapshot-pv \
  --name aci \
  --exec-command "bash -c 'echo \"$(cat qdrant_volume_snapshot.sh > /tmp/qdrant_volume_snapshot.sh) && chmod +x /tmp/qdrant_volume_snapshot.sh'"


  
  az container exec \
  --resource-group rg-qdrant-snapshot-pv \
  --name aci \
  --exec-command "bash -c 'echo \"$(echo "hola"  > /tmp/qdrant_volume_snapshot.sh) && chmod +x /tmp/qdrant_volume_snapshot.sh'"



az container exec --resource-group rg-qdrant-snapshot-pv --name aci --exec-command "bash -c 'echo \"$(head -n 50 qdrant_volume_snapshot.sh)\" > /tmp/parte1.sh'"

"bash -c 'echo \"$(cp qdrant_volume_snapshot.sh  /tmp/qdrant_volume_snapshot.sh) && chmod +x /tmp/qdrant_volume_snapshot.sh'"
"bash -c 'echo \"$(head -n 50 qdrant_volume_snapshot.sh)\" > /tmp/parte1.sh'"

 az container exec \
  --resource-group rg-qdrant-snapshot-pv \
  --name aci \
  --exec-command "bash -c 'echo \"$(head -n 50 qdrant_volume_snapshot.sh)\" > /tmp/parte1.sh'"


  ### workflow ###
  # Crear Storage Account

  1️⃣ Crear un Azure Storage Account y un File Share
# Crear Storage Account
az storage account create \
  --name mystorageacct123 \
  --resource-group rg-qdrant-snapshot-pv \
  --location eastus \
  --sku Standard_LRS

# Obtener la key
STORAGE_KEY=$(az storage account keys list \
  --account-name mystorageacct123 \
  --resource-group rg-qdrant-snapshot-pv \
  --query "[0].value" -o tsv)

# Crear File Share
az storage share create \
  --name scripts-share \
  --account-name mystorageacct123 \
  --account-key $STORAGE_KEY
2️⃣ Subir tu script al File Share
2️⃣ Subir tu script al File Share

az storage file upload \
  --share-name scripts-share \
  --source qdrant_volume_snapshot.sh \
  --path qdrant_volume_snapshot.sh \
  --account-name mystorageacct123 \
  --account-key $STORAGE_KEY

3️⃣ Crear el ACI y montar el File Share
az container create \
  --resource-group rg-qdrant-snapshot-pv \
  --name aci \
  --image mcr.microsoft.com/azure-cli \
  --azure-file-volume-share-name scripts-share \
  --azure-file-volume-account-name mystorageacct123 \
  --azure-file-volume-account-key $STORAGE_KEY \
  --azure-file-volume-mount-path /mnt/scripts \
  --command-line "/bin/bash -c 'tail -f /dev/null'"

4️⃣ Ejecutar tu script desde ACI
az container exec \
  --resource-group rg-qdrant-snapshot-pv \
  --name aci \
  --exec-command "bash /mnt/scripts/qdrant_volume_snapshot.sh dev rg-qdrant-snapshot-pv"
