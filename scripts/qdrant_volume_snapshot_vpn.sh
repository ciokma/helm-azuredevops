#!/usr/bin/env bash

# This script performs backups of Azure volumes and manages resources in Kubernetes.

# Usage:
# ./qdrant_volume_snapshot.sh <environment> <target_resource_group>
#
# Example:
# ./qdrant_volume_snapshot.sh dev backup-test-resource-group

# Parameters:
#   <environment>               The environment in which the script runs (dev, stg, uat, prod).
#   <target_resource_group>     The Azure resource group where the backup will be created.

# Dependencies:
# - Azure CLI
# - kubectl
# - jq

# Example Output:
# Start time: 2025-10-01 12:00:00
# Snapshot created in dev: my-disk-snapshot-202310011200
# Total execution time in dev: 30 seconds

declare -A SUBSCRIPTION

SUBSCRIPTION["dev"]="f9703f5b-83a3-4d1e-9872-e4b59e50de6e"
SUBSCRIPTION["stg"]=""
SUBSCRIPTION["uat"]=""
SUBSCRIPTION["prod"]=""

# Function to get volume information using 'az aks command invoke'
function get_by_claimref_remote() {
    local search_claim="$1"
    local resource_group="$2"
    local cluster_name="$3"

    # Use 'az aks command invoke' to run kubectl remotely
    # az aks command invoke \
    #     --resource-group "$resource_group" \
    #     --name "$cluster_name" \
    #     --command "kubectl get pv -n default -o json" | \
    #     jq \
    #     --arg search "$search_claim" \
    #     '.items[] | select(.spec.claimRef.name | contains($search)) | select(.spec.claimRef.namespace=="default")'
    # Paso 1: Obtener la información de los Persistent Volumes (PVs) del clúster y guardarla en una variable.

    # result=$(az aks command invoke \
    #     --resource-group "$resource_group" \
    #     --name "$cluster_name" \
    #     --command "kubectl get pv -n default -o json" \
    #     --query "logs" -o tsv)


    result=$(az aks command invoke \
        --resource-group "$resource_group" \
        --name "$cluster_name" \
        --command "kubectl get pv -n default -o json" \
        -o json | jq -r '.logs')

    #to avoid stout message
    # --query "logs" -o tsv
    # command started at 2025-08-19 21:03:46+00:00, finished at 2025-08-19 21:03:47+00:00 with exitcode=0
    
    echo "$result" | jq \
        --arg search "$search_claim" \
        '.items[] | select(.spec.claimRef.name | contains($search)) | select(.spec.claimRef.namespace=="default")'
}

# Function to get the volume or disk URI
function get_volume_or_disk() {
    local search_claim="$1"
    local resource_group="$2"
    local cluster_name="$3"
    
    # Get the volume handles remotely
    RESULT=$(get_by_claimref_remote "$search_claim" "$resource_group" "$cluster_name")
    HAS_AZURE_DISK=$(echo $RESULT | jq '.spec | has("azureDisk")')
    HAS_CSI=$(echo $RESULT | jq '.spec | has("csi")')
    if [[ "$HAS_AZURE_DISK" == "true" ]]; then
        echo $RESULT | jq -r '.spec.azureDisk.diskURI'
    elif [[ "$HAS_CSI" == "true" ]]; then
        echo $RESULT | jq -r '.spec.csi.volumeHandle'
    else
        echo "Error: Could not find disk URI for claim reference '$search_claim'"
        exit 1
    fi
}

# No longer needed as we use `az aks command invoke`
# function delete_kube_contexts() {
#     ...
# }

function get_snapshot_uri() {
    local ENVIRONMENT=${1,,}
    local CLUSTER_NAME="aks-$ENVIRONMENT"
    local RESOURCE_GROUP="rg-$ENVIRONMENT"
    local SUBSCRIPTION_ID="${SUBSCRIPTION["$ENVIRONMENT"]}"

    if [ -z "$SUBSCRIPTION_ID" ]; then
        echo "Error: Subscription ID is empty for environment '$ENVIRONMENT'."
        exit 1
    fi

    az account set --subscription "$SUBSCRIPTION_ID"
    
    # We no longer need to get the credentials locally
    # delete_kube_contexts
    # az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --admin --overwrite-existing > /dev/null 2>&1

    get_volume_or_disk "qdrant" "$RESOURCE_GROUP" "$CLUSTER_NAME"
}

function validate_parameter() {
    ENVIRONMENT=$1
    RESOURCE_GROUP=$2
    # VALIDATE ENVIRONMENT PARAMETER
    if [ -z "$ENVIRONMENT" ]; then
        echo "Error: No environment specified. Please provide 'dev', 'stg', 'uat', or 'prod'."
        exit 1
    # VALIDATE TARGET RESOURCE GROUP
    elif [ -z "$RESOURCE_GROUP" ]; then
        echo "Error: No target resource group specified. Please provide a target resource group in which the snapshot will be created."
        exit 1
    fi

    ENVIRONMENT=${1^^}

    # VALIDATE ENVIRONMENT VALUE
    case ${ENVIRONMENT} in
        "DEV" | "STG" | "UAT" | "PROD")
            # Valid environment, do nothing
            ;;
        * )
            echo "Error: Invalid environment specified. Please specify 'dev', 'stg', 'uat', or 'prod'."
            exit 1
            ;;
    esac
    # VALIDATE IF RESOURCE GROUP EXISTS
    if ! az group exists --name "$RESOURCE_GROUP" | grep -q true; then
        echo "Error: The specified resource group '$RESOURCE_GROUP' does not exist."
        exit 1
    fi
}

function create_snapshot() {
    local disk_uri="$1"
    local environment="$2"
    # The resource group in which the azure disk will be created.
    local target_resource_group="$3"
    # Get disk name
    local disk_name=$(echo "$disk_uri" | awk -F'/' '{print $NF}')
    # Unique snapshot name with timestamp
    local snapshot_name="${disk_name}-snapshot-$(date -u +"%Y%m%d%H%M")"

    # Record the start time
    START_TIME=$(date +%s)
    START_TIME_READABLE=$(date -d @$START_TIME '+%Y-%m-%d %H:%M:%S')

    # Display the start time
    echo "Start time: $START_TIME_READABLE"
    echo "snapshot_name $snapshot_name"
    echo "disk_uri $disk_uri"
    echo "target_resource_group $target_resource_group"
    # Create a snapshot from an existing disk in another resource group
    az snapshot create \
        --resource-group "$target_resource_group" \
        --name "$snapshot_name" \
        --source "$disk_uri" \
        --incremental false \
        --tags "createdBy=qdrant_volume_snapshot.sh" "env=$environment" "timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    if [[ $? -eq 0 ]]; then
        # Record the end time
        END_TIME=$(date +%s)
        # Calculate the total duration
        DURATION=$((END_TIME - START_TIME))
        # Display the result
        echo -e "\nSnapshot created in $environment: $snapshot_name"
        echo "Total execution time in $environment: $DURATION seconds"
    else
        echo -e "\nError creating snapshot of ${disk_id} in ${resource_group}"
    fi
}

function main() {
    echo "new version"
    ENVIRONMENT="$1"
    TARGET_RESOURCE_GROUP="$2"
    validate_parameter "$ENVIRONMENT" "$TARGET_RESOURCE_GROUP"
    DISK_URI=$(get_snapshot_uri "$ENVIRONMENT")
    if [ -z "$DISK_URI" ]; then
        echo "Error: No disk URI found. Exiting."
        exit 1
    fi
   create_snapshot "$DISK_URI" "$ENVIRONMENT" "$TARGET_RESOURCE_GROUP"
}

# execution example: ./qdrant_volume_snapshot.sh environment target-resource-group
main "$@"
