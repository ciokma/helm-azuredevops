data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-tfstates"
    storage_account_name = "sttfstateusdev"
    container_name       = "tfstate"
    key                  = "1-network.tfstate" # El nombre de estado del módulo 1
  }
}
