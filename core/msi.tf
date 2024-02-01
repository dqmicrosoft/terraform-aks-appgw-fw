resource "azurerm_user_assigned_identity" "aks_uami" {
  name                = "sme_aks_${var.alias}_uami"
  location            = var.location
  resource_group_name = data.terraform_remote_state.netcore.outputs.core_rg
}