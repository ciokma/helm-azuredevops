import datetime
import logging
import os

import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.resource import ResourceManagementClient
from kubernetes import client, config

# Definir tus suscripciones
SUBSCRIPTIONS = {
    "dev": "f9703f5b-83a3-4d1e-9872-e4b59e50de6e",
    "stg": "",
    "uat": "",
    "prod": ""
}

def main(mytimer: func.TimerRequest) -> None:
    utc_timestamp = datetime.datetime.utcnow().replace(
        tzinfo=datetime.timezone.utc).isoformat()

    logging.info(f"Qdrant snapshot function started at {utc_timestamp}")

    # Leer variables desde settings
    environment = os.getenv("ENVIRONMENT", "dev").lower()
    target_rg = os.getenv("TARGET_RESOURCE_GROUP", "rg-backups")

    subscription_id = SUBSCRIPTIONS.get(environment)
    if not subscription_id:
        logging.error(f"No subscription configured for environment '{environment}'")
        return

    # Autenticación con Managed Identity
    credential = DefaultAzureCredential()
    compute_client = ComputeManagementClient(credential, subscription_id)
    resource_client = ResourceManagementClient(credential, subscription_id)

    # Validar que el RG existe
    if not resource_client.resource_groups.check_existence(target_rg):
        logging.error(f"Resource group '{target_rg}' does not exist.")
        return

    # Cargar configuración de Kubernetes (usa kubeconfig en local o incluster en Azure)
    try:
        config.load_incluster_config()
    except:
        config.load_kube_config()

    v1 = client.CoreV1Api()
    pvs = v1.list_persistent_volume().items

    # Buscar el PV asociado a qdrant
    disk_uri = None
    for pv in pvs:
        claim = pv.spec.claim_ref
        if claim and "qdrant" in claim.name and claim.namespace == "default":
            if pv.spec.azure_disk:
                disk_uri = pv.spec.azure_disk.disk_uri
            elif pv.spec.csi:
                disk_uri = pv.spec.csi.volume_handle
            break

    if not disk_uri:
        logging.error("No disk found for qdrant PVC in namespace 'default'.")
        return

    # Crear snapshot
    disk_name = disk_uri.split("/")[-1]
    snapshot_name = f"{disk_name}-snapshot-{datetime.datetime.utcnow().strftime('%Y%m%d%H%M')}"

    logging.info(f"Creating snapshot {snapshot_name} from {disk_uri}")

    async_snapshot = compute_client.snapshots.begin_create_or_update(
        target_rg,
        snapshot_name,
        {
            "location": "eastus",  # ⚠️ Ajusta a la región de tu disco
            "creation_data": {
                "create_option": "Copy",
                "source_uri": disk_uri
            },
            "tags": {
                "createdBy": "qdrant_volume_snapshot_function",
                "env": environment,
                "timestamp": utc_timestamp
            }
        }
    )
    result = async_snapshot.result()

    logging.info(f"✅ Snapshot {result.name} created successfully in {target_rg}")
