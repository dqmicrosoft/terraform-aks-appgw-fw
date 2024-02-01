resource "azurerm_kubernetes_cluster" "aks" {
  name                       = "sme-${var.alias}-aks"
  location                   = var.location
  resource_group_name        = data.terraform_remote_state.netcore.outputs.aks_rg
  dns_prefix_private_cluster = "private-sme-${var.alias}-aks"
  private_cluster_enabled    = true
  private_dns_zone_id        = azurerm_private_dns_zone.aks.id

  identity {
    type         = "UserAssigned"
    identity_ids = [data.terraform_remote_state.core.outputs.msi_id]
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.appgw.id
  }

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.node_subnet.id
    pod_subnet_id  = azurerm_subnet.pod_subnet.id
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.10.0.10"
    service_cidr   = "10.10.0.0/24"
    outbound_type  = "userDefinedRouting"
  }

  depends_on = [
    azurerm_role_assignment.network_contributor,
    azurerm_role_assignment.dns_contributor,
    azurerm_route.aks_fw_route_to_internet,
    azurerm_route.aks_fw_route_to_internet
  ]
}
resource "azurerm_kubernetes_cluster_node_pool" "agic_nodepool" {
  name                  = "agic"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  vnet_subnet_id        = azurerm_subnet.node_subnet.id
  pod_subnet_id         = azurerm_subnet.pod_subnet.id

}