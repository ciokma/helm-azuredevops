import logging
import os
from datetime import datetime, timezone
from azure.functions import TimerRequest

import azure.functions as func
from azure.identity import DefaultAzureCredential, ManagedIdentityCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.containerservice import ContainerServiceClient
from kubernetes import client as k8s_client

from common.config import Appsetings

# Initialize configuration
config = Appsetings()


# --------------------------
# Helpers
# --------------------------

def get_credential():
    """Return AAD credential, prefer User Assigned Managed Identity if configured."""
    if config.user_assigned_identity_client_id:
        logging.info("Using User Assigned Managed Identity.")
        return ManagedIdentityCredential(client_id=config.user_assigned_identity_client_id)
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
    token = credential.get_token(config.aks_audience).token

    k8s_cfg = k8s_client.Configuration()
    k8s_cfg.host = host
    k8s_cfg.verify_ssl = False
    k8s_cfg.api_key = {"authorization": f"Bearer {token}"}
    k8s_client.Configuration.set_default(k8s_cfg)

    logging.info(f"Kubernetes client initialized for cluster {cluster_name}.")
    return k8s_client.CoreV1Api()

def get_pv_by_claim(name: str, v1, namespace: str = "default"):
    """Retrieve PV(s) bound to a given PVC name in a namespace."""
    pv_list = v1.list_persistent_volume()
    pv_json = k8s_client.ApiClient().sanitize_for_serialization(pv_list)
    logging.info("pv")
    logging.info(pv_json)
    matched = []
    for pv in pv_json.get("items", []):
        claim = pv.get("spec", {}).get("claimRef")
        if claim and claim.get("name") == name and claim.get("namespace") == namespace:
            matched.append(pv)

    logging.info(f"Found {len(matched)} PV(s) for qdrant_pattern '{name}' in namespace '{namespace}'.")
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

def create_snapshot(disk_uri: str):
    """Create an Azure snapshot from a disk URI."""
    compute_client = ComputeManagementClient(get_credential(), config.subscription_id)

    disk_name = os.path.basename(disk_uri)
    snapshot_name = f"{disk_name}-snapshot-{datetime.utcnow():%Y%m%d%H%M}"
    start_time = datetime.utcnow()

    snapshot_params = {
        "location": config.location,
        "creation_data": {"create_option": "Copy", "source_uri": disk_uri},
        "tags": {
            "createdBy": "qdrant_snapshot_function",
            "env": config.environment,
            "timestamp": start_time.isoformat() + "Z",
        },
    }

    logging.info(f"Creating snapshot '{snapshot_name}' for disk '{disk_uri}' in RG '{config.target_resource_group}'.")
    snapshot = compute_client.snapshots.begin_create_or_update(
        resource_group_name=config.target_resource_group,
        snapshot_name=snapshot_name,
        snapshot=snapshot_params
    ).result()

    duration = (datetime.utcnow() - start_time).total_seconds()
    logging.info(f"Snapshot '{snapshot_name}' created successfully in {duration:.2f}s.")
    return snapshot

# --------------------------
# Azure Function App
# --------------------------
def main(mytimer: TimerRequest) -> None:
    utc_timestamp = datetime.utcnow().replace(tzinfo=timezone.utc).isoformat()

    if mytimer.past_due:
        logging.info("The timer is past due!")

    logging.info("Python timer trigger function ran at %s", utc_timestamp)
    logging.info("Starting Qdrant snapshot function...")

    try:
        config.validate()
        v1 = build_k8s_client(get_credential(), config.subscription_id, config.resource_group, config.cluster_name)
        disk_uri = get_volume_or_disk(config.qdrant_pv_pattern, v1, config.k8s_namespace)

        if not disk_uri:
            logging.error(f"No disk URI found for PVC matching pattern '{config.qdrant_pv_pattern}'. Aborting snapshot creation.")
            return

        create_snapshot(disk_uri)
        logging.info("Qdrant snapshot function completed successfully.")

    except Exception as e:
        logging.error(f"Error in snapshot function: {type(e).__name__}: {e}")
        raise  # throw Exception
