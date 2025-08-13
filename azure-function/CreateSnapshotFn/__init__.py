import datetime
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient

# ⚠️ Configuración del disco
SUBSCRIPTION_ID = "<SUBSCRIPTION_ID>"
RESOURCE_GROUP = "<RG_DEL_DISCO>"
DISK_NAME = "<NOMBRE_DEL_DISCO>"
LOCATION = "<REGION_DEL_DISCO>"  # Ejemplo: eastus

def main(mytimer: func.TimerRequest) -> None:
    utc_timestamp = datetime.datetime.utcnow().replace(tzinfo=datetime.timezone.utc).isoformat()
    print(f"[INFO] Ejecutando snapshot a las {utc_timestamp}")

    # Autenticación con Managed Identity
    credential = DefaultAzureCredential()
    compute_client = ComputeManagementClient(credential, SUBSCRIPTION_ID)

    # Nombre único del snapshot
    snapshot_name = f"{DISK_NAME}-snap-{datetime.datetime.utcnow().strftime('%Y%m%d%H%M')}"

    # Parámetros del snapshot
    snapshot_params = {
        'location': LOCATION,
        'creation_data': {
            'create_option': 'Copy',
            'source_resource_id': f"/subscriptions/{SUBSCRIPTION_ID}/resourceGroups/{RESOURCE_GROUP}/providers/Microsoft.Compute/disks/{DISK_NAME}"
        },
        'tags': {
            'createdBy': 'AKS-Backup-Function',
            'timestamp': utc_timestamp
        }
    }

    # Crear snapshot
    poller = compute_client.snapshots.begin_create_or_update(
        resource_group_name=RESOURCE_GROUP,
        snapshot_name=snapshot_name,
        snapshot=snapshot_params
    )
    poller.result()

    print(f"[SUCCESS] Snapshot '{snapshot_name}' creado con éxito.")
