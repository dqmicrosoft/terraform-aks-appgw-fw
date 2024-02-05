data "terraform_remote_state" "aks" {
  backend = "azurerm"

  config = {
    resource_group_name  = "terraform"
    storage_account_name = "terraformdquaresma"
    container_name       = "akstfstate"
    key                  = "YOURKEY"
  }
}