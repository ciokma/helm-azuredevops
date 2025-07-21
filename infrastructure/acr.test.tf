# terraform.tf file is assuming these resources exist
# You got 3 errors:
# 1. Key Vault is not declared
# 2. Invalid SKU for PostgreSQL
# 3. Wrong resource name for PostgreSQL database

# Let's fix each of them step by step:

#  1. DECLARE THE KEY VAULT
# Add this block before using `local.key_vault_id`
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                        = "kvnameproxy"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}

locals {
  key_vault_id = azurerm_key_vault.main.id
}

#  2. FIX SKU NAME FOR FLEXIBLE POSTGRESQL SERVER
# You used "B1ms", but for PostgreSQL Flexible Server valid SKU tiers are like:
#  - GeneralPurpose
#  - MemoryOptimized
#  - Burstable (B_Standard)
# So use this instead:

resource "azurerm_postgresql_flexible_server" "name_proxy_db" {
  name                   = "nameproxydb"
  location               = var.location
  resource_group_name    = var.resource_group_name
  administrator_login    = var.name_proxy_db_username
  administrator_password = random_password.name_proxy_db_password.result
  version                = "13"

  sku_name   = "GP_Standard_D4s_v3" # Valid format
  storage_mb = 32768
  zone       = "1"

  delegated_subnet_id = null # Optional, remove if you have a VNet
  private_dns_zone_id = null
}

# 3. FIX DATABASE RESOURCE TYPE
# "azurerm_postgresql_flexible_database" DOES NOT EXIST
# Instead use: "azurerm_postgresql_flexible_server_database"

resource "azurerm_postgresql_flexible_server_database" "name_proxy_db" {
  name      = "nameproxydb"
  server_id = azurerm_postgresql_flexible_server.name_proxy_db.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}


resource "random_password" "name_proxy_master_key" {
  length = 32
  special = false
}

resource "azurerm_key_vault_secret" "name_proxy_master_key" {
  name = "name-proxy-master-key"
  value =  "sk-${random_password.name_proxy_master_key.result}"
  key_vault_id = local.key_vault_id
}

resource "random_password" "name_proxy_db_password"{ 
    length = 12
    special = false
}

resource "azurerm_key_vault_secret" "name_proxy_db_password" {
    name = "name-proxy-db-key"
    value = random_password.name_proxy_db_password.result
    key_vault_id = local.key_vault_id
}
resource "azurerm_key_vault_secret" "name_proxy_db_connection_string" {
  name  = "name-proxy-connection-string"
  value = "postgresql://${var.name_proxy_db_username}:${random_password.name_proxy_db_password.result}@${azurerm_postgresql_flexible_server.name_proxy_db.fqdn}:5432/${azurerm_postgresql_flexible_server_database.name_proxy_db.name}"
  key_vault_id = local.key_vault_id
}