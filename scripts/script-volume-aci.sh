#!/bin/bash
# Variables
RESOURCE_GROUP="rg-qdrant-snapshot-pv"
LOCATION="eastus"
STORAGE_ACCOUNT="mystorageacct123"
FILE_SHARE="scripts-share"
ACI_NAME="aci"
VNET_NAME="test-virtual-network"
SUBNET_NAME="default"
SCRIPT_NAME="qdrant_volume_snapshot.sh"

### 1️⃣ Crear Storage Account y File Share ###

# Crear Storage Account
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS

# Obtener la key
STORAGE_KEY=$(az storage account keys list \
  --account-name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --query "[0].value" -o tsv)

# Crear File Share
az storage share create \
  --name $FILE_SHARE \
  --account-name $STORAGE_ACCOUNT \
  --account-key $STORAGE_KEY

### 2️⃣ Subir tu script al File Share ###
az storage file upload \
  --share-name $FILE_SHARE \
  --source $SCRIPT_NAME \
  --path $SCRIPT_NAME \
  --account-name $STORAGE_ACCOUNT \
  --account-key $STORAGE_KEY

### 3️⃣ Crear el ACI dentro de la VNet ###
az container create \
  --resource-group $RESOURCE_GROUP \
  --name $ACI_NAME \
  --image mcr.microsoft.com/azure-cli \
  --azure-file-volume-share-name $FILE_SHARE \
  --azure-file-volume-account-name $STORAGE_ACCOUNT \
  --azure-file-volume-account-key $STORAGE_KEY \
  --azure-file-volume-mount-path /mnt/scripts \
  --vnet $VNET_NAME \
  --subnet $SUBNET_NAME \
  --command-line "/bin/bash -c 'tail -f /dev/null'"

### 4️⃣ Ejecutar tu script desde ACI ###
    az container exec \
    --resource-group $RESOURCE_GROUP \
    --name $ACI_NAME \
    --exec-command "bash /mnt/scripts/$SCRIPT_NAME dev $RESOURCE_GROUP"

### 5️⃣ (Opcional) Configurar kubectl dentro del ACI ###
# Una vez dentro del contenedor ACI puedes ejecutar:
# az aks get-credentials --resource-group rg-aks-dev --name aks-dev --admin --file /mnt/scripts/kubeconfig
# export KUBECONFIG=/mnt/scripts/kubeconfig
# kubectl get nodes
