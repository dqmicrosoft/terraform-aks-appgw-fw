resource "azurerm_container_registry" "acr" {
  name                          = "sme${var.alias}ACR"
  location                      = var.location
  resource_group_name           = data.terraform_remote_state.netcore.outputs.core_rg
  admin_enabled                 = false
  sku                           = "Premium"
  public_network_access_enabled = false
}

# Create azure container registry private endpoint
resource "azurerm_private_dns_zone" "acr_private_dns_zone" {
  name                = "privatelink.centralus.azurecr.io"
  resource_group_name = data.terraform_remote_state.netcore.outputs.netcore_rg
}

# Create azure private dns zone virtual network link for acr private endpoint vnet
resource "azurerm_private_dns_zone_virtual_network_link" "acr_private_dns_zone_virtual_network_link" {
  name                  = "acr-private-dns-zone-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.acr_private_dns_zone.name
  resource_group_name   = data.terraform_remote_state.netcore.outputs.netcore_rg
  virtual_network_id    = data.terraform_remote_state.netcore.outputs.vnet_hub_id
  depends_on            = [azurerm_private_dns_zone.acr_private_dns_zone]
}
resource "azurerm_private_dns_zone_virtual_network_link" "acr_private_dns_zone_virtual_network_link_aks" {
  name                  = "acr-private-dns-zone-vnet-link-aks"
  private_dns_zone_name = azurerm_private_dns_zone.acr_private_dns_zone.name
  resource_group_name   = data.terraform_remote_state.netcore.outputs.netcore_rg
  virtual_network_id    = data.terraform_remote_state.netcore.outputs.vnet_aks_id
  depends_on            = [azurerm_private_dns_zone.acr_private_dns_zone]
}

# Create azure private endpoint
resource "azurerm_private_endpoint" "acr_private_endpoint" {
  name                = "${azurerm_container_registry.acr.name}-private-endpoint"
  resource_group_name = data.terraform_remote_state.netcore.outputs.netcore_rg
  location            = var.location
  subnet_id           = data.terraform_remote_state.netcore.outputs.vnet_hub_hub_subnet_id


  private_service_connection {
    name                           = "${azurerm_container_registry.acr.name}-service-connection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names = [
      "registry"
    ]
  }

  private_dns_zone_group {
    name = azurerm_container_registry.acr.name

    private_dns_zone_ids = [
      azurerm_private_dns_zone.acr_private_dns_zone.id
    ]
  }

  depends_on = [azurerm_container_registry.acr]
}

resource "azurerm_private_dns_a_record" "acr_records" {
  count               = 2
  name                = [lower("${azurerm_container_registry.acr.name}.centralus.data"), lower(azurerm_container_registry.acr.name)][count.index]
  zone_name           = azurerm_private_dns_zone.acr_private_dns_zone.name
  resource_group_name = data.terraform_remote_state.netcore.outputs.netcore_rg
  ttl                 = 10
  records             = [[local.acr_data_ip, local.acr_ip][count.index]]
}