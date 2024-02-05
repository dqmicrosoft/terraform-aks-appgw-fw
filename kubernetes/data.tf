data "terraform_remote_state" "aks" {
  backend = "azurerm"

  config = {
    resource_group_name  = "terraform"
    storage_account_name = "terraformdquaresma"
    container_name       = "akstfstate"
    key                  = "7+LiTV+u+n6yZ3djdyLcYQIfpXOM9C3UNJ3vxIr233fHwB9ff9uD+ugXHPxZRXz/Va+pYLCXfk6U+AStJRBQ+A=="
  }
}