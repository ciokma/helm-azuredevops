#!/bin/bash
# Variables
LOCATION="eastus"
STORAGE_ACCOUNT="mystorageacct123"
FILE_SHARE="scripts-share"
ACI_NAME="aci-linux-azcli"
VNET_NAME="vnet-aks" #"test-virtual-network"
SUBNET_NAME="subnet-aci" #"subnet-aks" #"default"
SCRIPT_NAME="qdrant_volume_snapshot.sh"
SUBSCRIPTION_ID="f9703f5b-83a3-4d1e-9872-e4b59e50de6e"
RESOURCE_GROUP="rg-dev"
MC_rg="MC_rg-dev-eastus_aks-us-cluster_eastus"
ENVIRONMENT=$1
TARGET_RESOURCE_GROUP=$2

# create new subnet
#ommit in second attemp
#0. Create Subet in Vnet
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --address-prefixes "10.10.2.0/24"

#1. Create ACI
az container create \
  --resource-group $RESOURCE_GROUP \
  --name $ACI_NAME \
  --image mcr.microsoft.com/azure-cli \
  --os-type Linux \
  --assign-identity [system] \
  --vnet $VNET_NAME \
  --subnet $SUBNET_NAME \
  --restart-policy Always  \
  --cpu 1 \
  --memory 1 \
  --command-line "tail -f /dev/null"

#2. GET ACI_PRINCIPAL_ID
ACI_MI_PRINCIPAL_ID=$(az container show \
    --resource-group $RESOURCE_GROUP \
    --name $ACI_NAME \
    --query "identity.principalId" \
    -o tsv)

#total permisision
#3. Create Role Assigment
az role assignment create \
  --assignee $ACI_MI_PRINCIPAL_ID \
  --role "Contributor" \
  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups

# granular permission


# az role assignment create \
#   --assignee $ACI_MI_PRINCIPAL_ID \
#   --role "Contributor" \
#   --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP

# az role assignment create \
#   --assignee $ACI_MI_PRINCIPAL_ID\
#   --role Contributor \
#   --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$TARGET_RESOURCE_GROUP

# #permission to read from MC_
# az role assignment create \
#   --assignee $ACI_MI_PRINCIPAL_ID \
#   --role "Contributor" \
#   --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$MC_rg

# 4. Install kubectl
az container exec \
  --resource-group $RESOURCE_GROUP \
  --name $ACI_NAME \
  --exec-command "az aks install-cli"

#  run script
az container exec \
  --resource-group $RESOURCE_GROUP \
  --name $ACI_NAME \
  --exec-command "sh -s $ENVIRONMENT $TARGET_RESOURCE_GROUP" < ./qdrant_volume_snapshot.sh



 
#     az container exec \
#   --resource-group rg-dev-eastus \
#   --name aci-linux-azcli \
#   --exec-command "/bin/bash"

#     az container exec \
#   --resource-group rg-dev-eastus \
#   --name aci-linux-azcli \
#   --exec-command "az login --identity   account set --subscription f9703f5b-83a3-4d1e-9872-e4b59e50de6e "

#   az container exec \
#   --resource-group rg-dev-eastus \
#   --name aci-linux-azcli \
#   --exec-command "/bin/sh -c 'cat > /qdrant_volume_snapshot.sh && chmod +x /qdrant_volume_snapshot.sh'" < qdrant_volume_snapshot.sh


  # loguerate a azure con un service principal
#   az login --identity
#   az account set --subscription f9703f5b-83a3-4d1e-9872-e4b59e50de6e

#   az aks get-credentials \
#         --resource-group "rg-dev-eastus" \
#         --name "aks-us-cluster" \
#         --admin \
#         --overwrite-existing > /dev/null 2>&1
# kubectl get pv \
#         -n default \
#         -o json | \
#         jq \
#         --arg search "qdrant" \
#         '.items[]|select(.spec.claimRef.name | contains($search))|select(.spec.claimRef.namespace=="default")'