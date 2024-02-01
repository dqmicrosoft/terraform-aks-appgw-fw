output "netcore_rg" {
  value = azurerm_resource_group.netcore_rg.name
}
output "netcore_rg_id" {
  value = azurerm_resource_group.netcore_rg.id
}
output "core_rg" {
  value = azurerm_resource_group.core_rg.name
}
output "aks_rg" {
  value = azurerm_resource_group.aks_rg.name
}
output "vnet_hub_id" {
  value = azurerm_virtual_network.vnet_hub.id
}
output "vnet_hub_name" {
  value = azurerm_virtual_network.vnet_hub.name
}
output "vnet_aks_id" {
  value = azurerm_virtual_network.vnet_aks.id
}
output "vnet_aks_name" {
  value = azurerm_virtual_network.vnet_aks.name
}
output "vnet_hub_hub_subnet_id" {
  value = azurerm_subnet.hub_subnet.id
}
output "vnet_hub_appgw_subnet_id" {
  value = azurerm_subnet.appgw_subnet.id
}
output "hub_subnet_route_table_name" {
  value = azurerm_route_table.hub_subnet_route_table.name
}
output "appgw_subnet_route_table_name" {
  value = azurerm_route_table.appgw_subnet_route_table.name
}
output "vnet_aks_address_space" {
  value = azurerm_virtual_network.vnet_aks.address_space
}
output "appgw_subnet_nsg_name" {
  value = azurerm_network_security_group.appgw_subnet_nsg.name
}
output "vnet_hub_appgw_subnet_address_space" {
  value = azurerm_subnet.appgw_subnet.address_prefixes
}
