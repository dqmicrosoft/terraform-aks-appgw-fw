data "terraform_remote_state" "netcore" {
  backend = "azurerm"

  config = {
    resource_group_name  = "terraform"
    storage_account_name = "terraformdquaresma"
    container_name       = "netcoretfstate"
    key                  = "YOURKEY"
  }
}
data "terraform_remote_state" "core" {
  backend = "azurerm"

  config = {
    resource_group_name  = "terraform"
    storage_account_name = "terraformdquaresma"
    container_name       = "coretfstate"
    key                  = "YOURKEY"
  }
}
data "terraform_remote_state" "firewall" {
  backend = "azurerm"

  config = {
    resource_group_name  = "terraform"
    storage_account_name = "terraformdquaresma"
    container_name       = "fwtfstate"
    key                  = "YOURKEY"
  }
}