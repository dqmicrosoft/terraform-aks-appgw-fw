resource "azurerm_resource_group" "netcore_rg" {
  name     = "sme_netcore_${var.alias}_rg"
  location = var.location
}

# Create the core resource group
resource "azurerm_resource_group" "core_rg" {
  name     = "sme_core_${var.alias}_rg"
  location = var.location
}

# Create the aks resource group
resource "azurerm_resource_group" "aks_rg" {
  name     = "sme_aks_${var.alias}_rg"
  location = var.location
}
resource "azurerm_virtual_network" "vnet_hub" {
  name                = "sme_vnet_hub"
  resource_group_name = azurerm_resource_group.netcore_rg.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  depends_on          = [azurerm_resource_group.netcore_rg]
}

resource "azurerm_virtual_network" "vnet_aks" {
  name                = "sme_vnet_aks"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = var.location
  address_space       = ["10.1.0.0/16"]
  depends_on          = [azurerm_virtual_network.vnet_aks , azurerm_virtual_network.vnet_hub]
}

resource "azurerm_virtual_network_peering" "hub2spoke" {
  name                      = "hub2spoke"
  resource_group_name       = azurerm_resource_group.netcore_rg.name
  virtual_network_name      = azurerm_virtual_network.vnet_hub.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_aks.id
  depends_on          = [ azurerm_virtual_network.vnet_aks , azurerm_virtual_network.vnet_hub ]
}

resource "azurerm_virtual_network_peering" "spoke2hub" {
  name                      = "spoke2hub"
  resource_group_name       = azurerm_resource_group.aks_rg.name
  virtual_network_name      = azurerm_virtual_network.vnet_aks.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_hub.id
  depends_on          = [ azurerm_virtual_network.vnet_aks , azurerm_virtual_network.vnet_hub ]
}

resource "azurerm_subnet" "hub_subnet" {
  name                 = "sme_vnet_hub_subnet"
  resource_group_name  = azurerm_resource_group.netcore_rg.name
  virtual_network_name = azurerm_virtual_network.vnet_hub.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "hub_subnet_nsg" {
  subnet_id                 = azurerm_subnet.hub_subnet.id
  network_security_group_id = azurerm_network_security_group.hub_subnet_nsg.id
  depends_on                = [azurerm_network_security_group.hub_subnet_nsg]
}

resource "azurerm_subnet_route_table_association" "hub_subnet_route_table" {
  subnet_id      = azurerm_subnet.hub_subnet.id
  route_table_id = azurerm_route_table.hub_subnet_route_table.id
  depends_on     = [azurerm_route_table.hub_subnet_route_table]
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "sme_vnet_appgw_subnet"
  resource_group_name  = azurerm_resource_group.netcore_rg.name
  virtual_network_name = azurerm_virtual_network.vnet_hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "appgw_subnet_nsg" {
  subnet_id                 = azurerm_subnet.appgw_subnet.id
  network_security_group_id = azurerm_network_security_group.appgw_subnet_nsg.id
  depends_on                = [azurerm_network_security_group.appgw_subnet_nsg]
}

resource "azurerm_subnet_route_table_association" "appgw_subnet_route_table" {
  subnet_id      = azurerm_subnet.appgw_subnet.id
  route_table_id = azurerm_route_table.appgw_subnet_route_table.id
  depends_on     = [azurerm_route_table.appgw_subnet_route_table]
}

resource "azurerm_virtual_network_dns_servers" "vnet_aks" {
  virtual_network_id = azurerm_virtual_network.vnet_aks.id
  dns_servers        = [azurerm_network_interface.dns_nic.private_ip_address]
  depends_on         = [azurerm_linux_virtual_machine.dns_server]
}

