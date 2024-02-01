resource "azurerm_route_table" "hub_subnet_route_table" {
  name                = "vnet_hub_hub_subnet_route_table"
  location            = var.location
  resource_group_name = azurerm_resource_group.netcore_rg.name
}

resource "azurerm_route_table" "appgw_subnet_route_table" {
  name                = "vnet_hub_appgw_subnet_route_table"
  location            = var.location
  resource_group_name = azurerm_resource_group.netcore_rg.name
}

resource "azurerm_network_security_group" "hub_subnet_nsg" {
  name                = "vnet_hub_hub_subnet_nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.netcore_rg.name
}

resource "azurerm_network_security_group" "appgw_subnet_nsg" {
  name                = "vnet_hub_appgw_subnet_nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.netcore_rg.name
}

