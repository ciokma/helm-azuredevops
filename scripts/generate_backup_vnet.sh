
#!/bin/bash
# Variables
TARGET_RESOURCE_GROUP="rg-qdrant-snapshot-pv"
ACI_NAME="aci-linux-azcli"
ENVIRONMENT=$1
TARGET_RESOURCE_GROUP=$2
RESOURCE_GROUP="rg-dev"
# ejecutar script
# az container exec   --resource-group $RESOURCE_GROUP   --name $ACI_NAME   --exec-command "/bin/sh" < ./qdrant_volume_snapshot.sh $ENVIRONMENT $TARGET_RESOURCE_GROUP

# az container exec \
#   --resource-group $RESOURCE_GROUP \
#   --name $ACI_NAME \
#   --exec-command "sh -s" < ./install-azure-cli-kubectl-aci.sh 


 az container exec \
   --resource-group $RESOURCE_GROUP \
   --name $ACI_NAME \
   --exec-command "sh -s $ENVIRONMENT $TARGET_RESOURCE_GROUP" < ./qdrant_volume_snapshot.sh 

# az container exec \
#   --resource-group $RESOURCE_GROUP \
#   --name $ACI_NAME \
#   --exec-command "sh -s $ENVIRONMENT $TARGET_RESOURCE_GROUP ; exit" < ./qdrant_volume_snapshot.sh \
# && az container delete \
#   --resource-group rg-dev-eastus \
#   --name aci-linux-azcli \
#   --yes
