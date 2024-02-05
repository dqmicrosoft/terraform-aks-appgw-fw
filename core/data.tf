data "terraform_remote_state" "netcore" {
  backend = "azurerm"

  config = {
    resource_group_name  = "terraform"
    storage_account_name = "terraformdquaresma"
    container_name       = "netcoretfstate"
    key                  = "YOURKEY"
  }
}