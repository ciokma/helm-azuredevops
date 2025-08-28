terraform {
  backend "azurerm" {
    subscription_id      = "f9703f5b-83a3-4d1e-9872-e4b59e50de6e"
    resource_group_name  = "rg-tfstates"
    storage_account_name = "sttfstateusdev"
    container_name       = "tfstate"
    key                  = "1-network.tfstate"
  }
}
