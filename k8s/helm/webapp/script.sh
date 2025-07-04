# VARIABLES
RESOURCE_GROUP="aks-us-test-rg"
ACR_NAME="acrregistryciokmauedev"
ACR_LOGIN_SERVER="$ACR_NAME.azurecr.io"
CHART_NAME="webapp"
CHART_VERSION="0.1.0"
CHART_PATH="../webapp"

# 1. Crear ACR si no existe
az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP &>/dev/null || \
az acr create \
  --name $ACR_NAME \
  --resource-group $RESOURCE_GROUP \
  --sku Basic \
  --admin-enabled true

# 2. Login al ACR
az acr login --name $ACR_NAME

# 3. Empaquetar el Helm chart
helm package $CHART_PATH --version $CHART_VERSION -d .

# 4. Push a ACR (modo OCI)
export HELM_EXPERIMENTAL_OCI=1
helm push "${CHART_NAME}-${CHART_VERSION}.tgz" "oci://$ACR_LOGIN_SERVER/charts"
