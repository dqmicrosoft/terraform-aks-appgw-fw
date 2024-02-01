resource "azurerm_subnet" "node_subnet" {
  name                 = "sme_vnet_aks_subnet_nodes"
  resource_group_name  = data.terraform_remote_state.netcore.outputs.aks_rg
  virtual_network_name = data.terraform_remote_state.netcore.outputs.vnet_aks_name
  address_prefixes     = var.node_subnet_range
}

resource "azurerm_subnet" "pod_subnet" {
  name                 = "sme_vnet_aks_subnet_pods"
  resource_group_name  = data.terraform_remote_state.netcore.outputs.aks_rg
  virtual_network_name = data.terraform_remote_state.netcore.outputs.vnet_aks_name
  address_prefixes     = var.pod_subnet_range
  delegation {
    name = "Microsoft.ContainerService.managedClusters"
    service_delegation {
      actions = [
      "Microsoft.Network/virtualNetworks/subnets/join/action", ]
      name = "Microsoft.ContainerService/managedClusters"
    }
  }
}


resource "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.centralus.azmk8s.io"
  resource_group_name = data.terraform_remote_state.netcore.outputs.netcore_rg
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_hub_link" {
  name                  = "aks-private-dns-zone-vnet-link-hub"
  resource_group_name   = data.terraform_remote_state.netcore.outputs.netcore_rg
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = data.terraform_remote_state.netcore.outputs.vnet_hub_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_aks_link" {
  name                  = "aks-private-dns-zone-vnet-link-aks"
  resource_group_name   = data.terraform_remote_state.netcore.outputs.netcore_rg
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = data.terraform_remote_state.netcore.outputs.vnet_aks_id
}