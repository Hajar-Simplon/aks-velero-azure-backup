terraform {
  backend "azurerm" {
    resource_group_name  = "hmezouarRG"
    storage_account_name = "tfstatehmez0c93dc"
    container_name       = "tfstate"
    key                  = "aks-velero.tfstate"
    use_azuread_auth     = true
  }
}
