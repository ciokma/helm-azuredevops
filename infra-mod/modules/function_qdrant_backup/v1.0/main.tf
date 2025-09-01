# Random
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

# Storage Account para la Function App
resource "azurerm_storage_account" "function_sa" {
  name                     = "stfunc${random_integer.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Contenedor privado para el archivo de la función
resource "azurerm_storage_container" "function_container" {
  name                  = "function-app-code"
  storage_account_id    = azurerm_storage_account.function_sa.id
  container_access_type = "private"
}

# Service Plan (Flex Consumption)
resource "azurerm_service_plan" "function_plan_flex" {
  name                = "${var.function_name}-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "FC1"
  os_type             = "Linux"
}

# User Assigned Identity
resource "azurerm_user_assigned_identity" "function_identity" {
  name                = "${var.function_name}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Empaquetar el código de la función en zip
data "archive_file" "python_function_package" {
  type        = "zip"
  source_dir  = "${path.module}/function_code"
  output_path = "${path.module}/function_code.zip"
}

# Log Analytics
resource "azurerm_log_analytics_workspace" "log_analytics_ws" {
  name                = "${var.function_name}-la"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "${var.function_name}-ai"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_ws.id
}

# Function App Flex Consumption
resource "azurerm_function_app_flex_consumption" "function" {
  name                = var.function_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.function_plan_flex.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.function_sa.primary_blob_endpoint}${azurerm_storage_container.function_container.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.function_sa.primary_access_key

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.function_identity.id]
  }

  runtime_name           = "python"
  runtime_version        = "3.11"
  maximum_instance_count = 50
  instance_memory_in_mb  = 2048

  # Only set VNet if specified
  virtual_network_subnet_id = var.create_in_vnet ? var.function_vnet_subnet_id : null

  site_config {
    http2_enabled      = false
    websockets_enabled = false
  }

  app_settings = {
    AzureWebJobsStorage   = azurerm_storage_account.function_sa.primary_connection_string
    AZURE_CLIENT_ID       = azurerm_user_assigned_identity.function_identity.client_id
    AZURE_SUBSCRIPTION_ID = var.subscription_id
    LOCATION              = var.location
    CLUSTER_NAME          = var.aks_cluster_name
    RESOURCE_GROUP_NAME   = var.resource_group_name
    TARGET_RESOURCE_GROUP = var.target_resource_group_name
    ENVIRONMENT           = var.environment
    QDRANT_PV_PATTERN     = var.qdrant_pv_pattern
    QDRANT_NAMESPACE      = var.qdrant_namespace
    CRON_SCHEDULE         = var.cron_schedule
    # Audience for getting tokens AAD with the API de AKS API
    AKS_AUDIENCE                          = var.aks_audience
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.app_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.app_insights.connection_string
  }
  lifecycle {
    ignore_changes = [
      # This will ignore any changes to the app_settings map that are not in the code.
      # The keys you define above will still be managed.
      # app_settings,
      tags,
      site_config
    ]
  }
}

# Deploy Function Code
resource "null_resource" "function_deploy" {
  depends_on = [azurerm_function_app_flex_consumption.function]

  triggers = {
    zip_file_md5 = data.archive_file.python_function_package.output_md5
  }

  provisioner "local-exec" {
    command     = "az functionapp deployment source config-zip -g ${var.resource_group_name} -n ${azurerm_function_app_flex_consumption.function.name} --src ${data.archive_file.python_function_package.output_path}"
    interpreter = ["/bin/bash", "-c"]
  }
}
