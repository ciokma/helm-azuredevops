import datetime
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient

# ⚙️ Configuración
SUBSCRIPTION_ID = "<SUBSCRIPTION_ID>"
RESOURCE_GROUP = "<RG_DEL_DISCO>"
DISK_NAME = "<NOMBRE_DEL_DISCO>"
LOCATION = "<REGION_DEL_DISCO>"
MAX_SNAPSHOTS = 5  # Mantener solo los últimos 5

def main(mytimer: func.TimerRequest) -> None:
    utc_timestamp = datetime.datetime.utcnow().replace(tzinfo=datetime.timezone.utc).isoformat()
    print(f"[INFO] Ejecutando limpieza de snapshots a las {utc_timestamp}")

    credential = DefaultAzureCredential()
    compute_client = ComputeManagementClient(credential, SUBSCRIPTION_ID)

    # Listar todos los snapshots del grupo
    snapshots = compute_client.snapshots.list_by_resource_group(RESOURCE_GROUP)

    # Filtrar los que corresponden a este disco
    snapshots_for_disk = [
        s for s in snapshots if s.name.startswith(f"{DISK_NAME}-snap-")
    ]

    # Ordenar por fecha de creación descendente
    snapshots_for_disk.sort(key=lambda s: s.time_created, reverse=True)

    # Eliminar los que excedan el límite
    if len(snapshots_for_disk) > MAX_SNAPSHOTS:
        old_snaps = snapshots_for_disk[MAX_SNAPSHOTS:]
        for snap in old_snaps:
            print(f"[INFO] Eliminando snapshot antiguo: {snap.name}")
            poller = compute_client.snapshots.begin_delete(RESOURCE_GROUP, snap.name)
            poller.result()
    else:
        print("[INFO] No hay snapshots para eliminar.")

    print("[SUCCESS] Limpieza de snapshots finalizada.")
