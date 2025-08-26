import logging
import os
from datetime import datetime

import azure.functions as func
from azure.identity import DefaultAzureCredential, ManagedIdentityCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.containerservice import ContainerServiceClient
from kubernetes import client as k8s_client

# Audience para tokens AAD contra el API de AKS
AKS_AUDIENCE = "6dae42f8-4368-4678-94ff-3960e28e3630/.default"

# --------------------------
# Subscription IDs per environment
# --------------------------
SUBSCRIPTIONS = {
    "dev": "f9703f5b-83a3-4d1e-9872-e4b59e50de6e",
    "stg": "",
    "uat": "",
    "prod": ""
}

# --------------------------
# Azure Function App
# --------------------------
app = func.FunctionApp()

# --------------------------
# Helpers
# --------------------------

def get_credential():
    """Return AAD credential, prefer User Assigned Managed Identity if configured."""
    client_id = os.getenv("USER_ASSIGNED_IDENTITY_CLIENT_ID")
    if client_id:
        logging.info("Using User Assigned Managed Identity.")
        return ManagedIdentityCredential(client_id=client_id)
    logging.info("Using DefaultAzureCredential.")
    return DefaultAzureCredential(exclude_shared_token_cache_credential=True)

def build_k8s_client(credential, subscription_id, rg_name, cluster_name):
    """Build Kubernetes client authenticated with AAD token."""
    cs_client = ContainerServiceClient(credential, subscription_id)
    mc = cs_client.managed_clusters.get(rg_name, cluster_name)

    fqdn = getattr(mc, "private_fqdn", None) or getattr(mc, "fqdn", None)
    if not fqdn:
        raise RuntimeError("Could not get AKS API server FQDN.")

    host = f"https://{fqdn}"
    token = credential.get_token(AKS_AUDIENCE).token

    cfg = k8s_client.Configuration()
    cfg.host = host
    cfg.verify_ssl = False
    cfg.api_key = {"authorization": f"Bearer {token}"}
    k8s_client.Configuration.set_default(cfg)

    logging.info(f"Kubernetes client initialized for cluster {cluster_name}.")
    return k8s_client.CoreV1Api()

def get_pv_by_claim(name: str, v1, namespace: str = "default"):
    """Retrieve PV(s) bound to a given PVC name in a namespace."""
    pv_list = v1.list_persistent_volume()
    pv_json = k8s_client.ApiClient().sanitize_for_serialization(pv_list)

    matched = []
    for pv in pv_json.get("items", []):
        claim = pv.get("spec", {}).get("claimRef")
        if claim and claim.get("name") == name and claim.get("namespace") == namespace:
            matched.append(pv)

    logging.info(f"Found {len(matched)} PV(s) for PVC '{name}' in namespace '{namespace}'.")
    return matched

def get_volume_or_disk(name: str, v1, namespace: str = "default"):
    """Return the disk URI for a PVC, supporting AzureDisk and CSI drivers."""
    matched_pvs = get_pv_by_claim(name, v1, namespace)
    if not matched_pvs:
        logging.error(f"No PVs found for PVC '{name}' in namespace '{namespace}'.")
        return None

    pv = matched_pvs[0]
    spec = pv.get("spec", {})

    if "csi" in spec and "volumeHandle" in spec["csi"]:
        logging.info(f"PV '{pv['metadata']['name']}' is backed by CSI volume.")
        return spec["csi"]["volumeHandle"]

    if "azureDisk" in spec and "diskURI" in spec["azureDisk"]:
        logging.info(f"PV '{pv['metadata']['name']}' is backed by AzureDisk.")
        return spec["azureDisk"]["diskURI"]

    logging.error(f"PV '{pv['metadata']['name']}' has no recognized disk type.")
    return None

def create_snapshot(disk_uri: str, environment: str, target_resource_group: str, credential, subscription_id: str):
    """Create an Azure snapshot from a disk URI."""
    compute_client = ComputeManagementClient(credential, subscription_id)

    disk_name = os.path.basename(disk_uri)
    snapshot_name = f"{disk_name}-snapshot-{datetime.utcnow():%Y%m%d%H%M}"
    start_time = datetime.utcnow()

    snapshot_params = {
        "location": "eastus",  # TODO: ajustar si tu disco está en otra región
        "creation_data": {
            "create_option": "Copy",
            "source_uri": disk_uri
        },
        "tags": {
            "createdBy": "qdrant_snapshot_function",
            "env": environment,
            "timestamp": start_time.isoformat() + "Z"
        }
    }

    logging.info(f"Creating snapshot '{snapshot_name}' for disk '{disk_uri}' in RG '{target_resource_group}'.")
    snapshot = compute_client.snapshots.begin_create_or_update(
        resource_group_name=target_resource_group,
        snapshot_name=snapshot_name,
        snapshot=snapshot_params
    ).result()

    duration = (datetime.utcnow() - start_time).total_seconds()
    logging.info(f"Snapshot '{snapshot_name}' created successfully in {duration:.2f}s.")
    return snapshot

def validate_parameters(environment: str, target_resource_group: str):
    """Validate environment and RG input."""
    if environment.lower() not in SUBSCRIPTIONS.keys():
        raise ValueError(f"Invalid environment '{environment}'. Must be one of {list(SUBSCRIPTIONS.keys())}")
    if not target_resource_group:
        raise ValueError("Target resource group must be provided")
    logging.info(f"Parameters validated: env={environment}, RG={target_resource_group}")

# --------------------------
# Timer Trigger Function
# --------------------------
@app.timer_trigger(
    schedule="0 0 12 * * *",  # 0 */1 * * * * => 1 minute {second} {minute} {hour} {day} {month} {day-of-week}
    arg_name="myTimer",
    run_on_startup=False,
    use_monitor=False
)
def qdrant_snapshot_azfunction(myTimer: func.TimerRequest) -> None:
    if myTimer.past_due:
        logging.warning("Timer is past due!")

    logging.info("Starting Qdrant snapshot function...")

    environment = os.getenv("ENVIRONMENT", "dev").lower()
    target_resource_group = os.getenv("TARGET_RESOURCE_GROUP", "")
    cluster_name = os.getenv("CLUSTER_NAME", f"aks-{environment}")
    resource_group = os.getenv("AZURE_RESOURCE_GROUP_NAME", f"rg-{environment}")

    try:
        validate_parameters(environment, target_resource_group)

        credential = get_credential()
        subscription_id = SUBSCRIPTIONS[environment]

        v1 = build_k8s_client(credential, subscription_id, resource_group, cluster_name)

        disk_uri = get_volume_or_disk("qdrant-pvc", v1, "default")
        if not disk_uri:
            logging.error("No disk URI found for PVC 'qdrant-pvc'. Aborting snapshot creation.")
            return

        create_snapshot(disk_uri, environment, target_resource_group, credential, subscription_id)

        logging.info("Qdrant snapshot function completed successfully.")

    except Exception as e:
        logging.error(f"Error in snapshot function: {e}", exc_info=True)
