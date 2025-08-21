#!/bin/bash
set -euo pipefail

#######################################
# Global configuration
#######################################
LOCATION="eastus"
ACI_NAME="aci-linux-azcli"
VNET_NAME="vnet-aks"
SUBNET_NAME="subnet-aci"
SUBSCRIPTION_ID="f9703f5b-83a3-4d1e-9872-e4b59e50de6e"
RESOURCE_GROUP="rg-dev"
SCRIPT_NAME="qdrant_volume_snapshot.sh"

# Arguments
ENVIRONMENT="${1:-}"
TARGET_RESOURCE_GROUP="${2:-}"

if [[ -z "$ENVIRONMENT" || -z "$TARGET_RESOURCE_GROUP" ]]; then
  >&2 echo "[ERROR] Usage: $0 <ENVIRONMENT> <TARGET_RESOURCE_GROUP>"
  exit 1
fi

#######################################
# Functions
#######################################

create_subnet() {
  echo "[INFO] Creating subnet: $SUBNET_NAME in VNet: $VNET_NAME..."
  az network vnet subnet create \
    --resource-group "$RESOURCE_GROUP" \
    --vnet-name "$VNET_NAME" \
    --name "$SUBNET_NAME" \
    --address-prefixes "10.10.2.0/24"
}

create_aci() {
  echo "[INFO] Creating Azure Container Instance: $ACI_NAME..."
  az container create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$ACI_NAME" \
    --image mcr.microsoft.com/azure-cli \
    --os-type Linux \
    --assign-identity [system] \
    --vnet "$VNET_NAME" \
    --subnet "$SUBNET_NAME" \
    --restart-policy Never \
    --cpu 1 \
    --memory 1 \
    --command-line "tail -f /dev/null"
}

get_aci_principal_id() {
  az container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$ACI_NAME" \
    --query "identity.principalId" \
    -o tsv
}

assign_role() {
  local principal_id="$1"
  echo "[INFO] Assigning Contributor role to $principal_id on Resource Groups scope..."
  az role assignment create \
    --assignee "$principal_id" \
    --role "Contributor" \
    --scope "/subscriptions/$SUBSCRIPTION_ID"
}

install_kubectl_in_aci() {
  echo "[INFO] Installing kubectl inside the ACI..."
  az container exec \
    --resource-group "$RESOURCE_GROUP" \
    --name "$ACI_NAME" \
    --exec-command "az aks install-cli"
}

run_snapshot_script() {
  echo "[INFO] Executing script $SCRIPT_NAME inside the container..."
  az container exec \
    --resource-group "$RESOURCE_GROUP" \
    --name "$ACI_NAME" \
    --exec-command "sh -s $ENVIRONMENT $TARGET_RESOURCE_GROUP" < "./$SCRIPT_NAME"
}

cleanup_resources() {
  echo "[INFO] Cleaning up temporary resources..."
  az container delete \
    --resource-group "$RESOURCE_GROUP" \
    --name "$ACI_NAME" \
    --yes || >&2 echo "[WARN] Failed to delete ACI $ACI_NAME"

  az network vnet subnet delete \
    --resource-group "$RESOURCE_GROUP" \
    --vnet-name "$VNET_NAME" \
    --name "$SUBNET_NAME" || >&2 echo "[WARN] Failed to delete Subnet $SUBNET_NAME"
}
wait_for_role() {
  local principal_id="$1"
  local max_attempts=5
  local attempt=1

  while (( attempt <= max_attempts )); do
    echo "[INFO] Checking role assignment propagation... attempt $attempt"
    if az role assignment list --assignee "$principal_id" \
         --scope "/subscriptions/$SUBSCRIPTION_ID" \
         --query "[].roleDefinitionName" -o tsv | grep -q "Contributor"; then
      echo "[INFO] Role assignment is active."
      return 0
    fi
    attempt=$(( attempt + 1 ))
    sleep 15
  done

  >&2 echo "[ERROR] Role assignment did not propagate in time."
  exit 1
}
#######################################
# Main workflow
#######################################

main() {
  # Ensure cleanup runs always (success or failure)
  trap cleanup_resources EXIT

  create_subnet
  create_aci
  local aci_principal_id
  aci_principal_id="$(get_aci_principal_id)"
  assign_role "$aci_principal_id"
  echo "[INFO] Waiting for role assignment to propagate..."
  sleep 60
  #wait_for_role "$aci_principal_id"
  install_kubectl_in_aci
  run_snapshot_script
}

main "$@"
