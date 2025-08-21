# Inicia sesión en tu cuenta de Azure si aún no lo has hecho
az login

# Establece tu suscripción por defecto (opcional, pero buena práctica)
az account set --subscription "f9703f5b-83a3-4d1e-9872-e4b59e50de6e"

# Crea el grupo de recursos
# az group create --name "rg-qdrant-snapshot-pv" --location "eastus"

# Crea la cuenta de almacenamiento
az storage account create \
  --name "rgqdrantsnapshotpvbeeb" \
  --resource-group "rg-qdrant-snapshot-pv" \
  --location "eastus" \
  --sku Standard_LRS

# Crea el plan de consumo (Flex Consumption)
# Nota: La CLI de Azure actualmente no tiene un comando dedicado para "Flex Consumption".
# Se especifica al crear la Function App.

az functionapp create \
  --name "qdrant-volume-snapshot-az-function" \
  --resource-group "rg-qdrant-snapshot-pv" \
  --storage-account "qdrantsnapshotstorage" \
  --consumption-plan-location "eastus" \
  --runtime "python" \
  --runtime-version "3.12" \
  --functions-version "4" \
  --os-type Linux

func azure functionapp publish "volume-snapshot-pv"

# este funciona para crear app functions
az functionapp create --resource-group "rg-qdrant-snapshot-pv" --name qdrant-volume-snapshot-az-function --flexconsumption-location eastus --runtime python --runtime-version "3.12" --storage-account "qdrantsnapshotstorage" --deployment-storage-auth-type UserAssignedIdentity

func azure functionapp publish "qdrant-volume-snapshot-az-function"