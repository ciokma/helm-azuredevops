# Random para nombres únicos
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

# 1. Storage Account para la Function App
resource "azurerm_storage_account" "function_sa" {
  name                     = "stfunc${random_integer.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# 2. Contenedor privado para el archivo de la función
resource "azurerm_storage_container" "function_container" {
  name                  = "function-app-code"
  storage_account_id    = azurerm_storage_account.function_sa.id
  container_access_type = "private"
}

# 3. Service Plan (Flex Consumption)
resource "azurerm_service_plan" "function_plan_flex" {
  name                = "ASP-rgdev-flex"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "FC1"
  os_type             = "Linux"
}

# 4. User Assigned Identity
resource "azurerm_user_assigned_identity" "function_identity" {
  name                = "func-backup-identity"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 5. Empaquetar el código de la función en un zip
data "archive_file" "python_function_package" {
  type        = "zip"
  source_dir  = "${path.module}/function_code"
  output_path = "${path.module}/function_code.zip"
}

resource "azurerm_log_analytics_workspace" "log_analytics_ws" {
  name                = "workspace-test"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
# 7. Application Insights para el monitoreo
resource "azurerm_application_insights" "app_insights" {
  name                = "app-insights-func-aks-backup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_ws.id
}
# 8. Function App Flex Consumption
resource "azurerm_function_app_flex_consumption" "function" {
  name                = "func-aks-backup"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.function_plan_flex.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.function_sa.primary_blob_endpoint}${azurerm_storage_container.function_container.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.function_sa.primary_access_key

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.function_identity.id]
  }

  runtime_name              = "python"
  runtime_version           = "3.11"
  maximum_instance_count    = 50
  instance_memory_in_mb     = 2048
  virtual_network_subnet_id = azurerm_subnet.subnet_function.id

  site_config {
    http2_enabled      = false
    websockets_enabled = false
  }

  app_settings = {

    AzureWebJobsStorage       = azurerm_storage_account.function_sa.primary_connection_string
    AZURE_CLIENT_ID           = azurerm_user_assigned_identity.function_identity.client_id
    AZURE_TENANT_ID           = var.tenant_id
    AZURE_SUBSCRIPTION_ID     = var.subscription_id
    CLUSTER_NAME              = var.aks_cluster_name
    AZURE_RESOURCE_GROUP_NAME = var.resource_group_name
    TARGET_RESOURCE_GROUP     = var.tg_resource_group_name
    ENVIRONMENT               = var.environment

    # Vincula Application Insights
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.app_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.app_insights.connection_string
  }
}

resource "null_resource" "function_deploy" {
  # Asegura que el recurso de la Function App se haya creado antes de intentar el despliegue
  depends_on = [azurerm_function_app_flex_consumption.function]

  # Monitorea los cambios en el archivo ZIP del código de la función
  triggers = {
    zip_file_md5 = data.archive_file.python_function_package.output_md5
  }

  provisioner "local-exec" {
    command     = "az functionapp deployment source config-zip -g ${azurerm_resource_group.rg.name} -n ${azurerm_function_app_flex_consumption.function.name} --src ${data.archive_file.python_function_package.output_path}"
    interpreter = ["/bin/bash", "-c"]
  }
}