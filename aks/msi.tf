resource "azurerm_user_assigned_identity" "aks_cp_identity" {
  name                = "aks_cp_identity"
  resource_group_name = data.terraform_remote_state.netcore.outputs.aks_rg
  location            = var.location
}

resource "azurerm_role_assignment" "dns_contributor" {
  scope                = azurerm_private_dns_zone.aks.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = data.terraform_remote_state.core.outputs.msi_principal_id
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = data.terraform_remote_state.netcore.outputs.vnet_aks_id
  role_definition_name = "Network Contributor"
  principal_id         = data.terraform_remote_state.core.outputs.msi_principal_id
}

resource "azurerm_role_assignment" "acr" {
  scope                = data.terraform_remote_state.core.outputs.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "appgw" {
  scope                = data.terraform_remote_state.netcore.outputs.netcore_rg_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}