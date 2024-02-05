resource "azurerm_route_table" "aks_route_table" {
  name                = "aks_route_table"
  location            = var.location
  resource_group_name = data.terraform_remote_state.netcore.outputs.aks_rg
}

resource "azurerm_route" "aks_fw_route" {
  name                   = "aks_fw_route"
  resource_group_name    = data.terraform_remote_state.netcore.outputs.aks_rg
  route_table_name       = azurerm_route_table.aks_route_table.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = data.terraform_remote_state.firewall.outputs.private_ip_address
}

resource "azurerm_route" "aks_fw_route_to_internet" {
  name                = "aks_fw_route_to_internet"
  resource_group_name = data.terraform_remote_state.netcore.outputs.aks_rg
  route_table_name    = azurerm_route_table.aks_route_table.name
  address_prefix      = "${data.terraform_remote_state.firewall.outputs.public_ip_address}/32"
  next_hop_type       = "Internet"
}

# resource "azurerm_route" "appgw_route_to_fw" {
#   name                = "appgw_route_to_fw"
#   resource_group_name = data.terraform_remote_state.netcore.outputs.netcore_rg
#   route_table_name       = data.terraform_remote_state.netcore.outputs.appgw_subnet_route_table_name
#   address_prefix         = data.terraform_remote_state.netcore.outputs.vnet_aks_address_space[0]
#   next_hop_type          = "VirtualAppliance"
#   next_hop_in_ip_address = data.terraform_remote_state.firewall.outputs.private_ip_address
# }
# resource "azurerm_route" "aks_route_to_fw" {
#   name                = "aks_route_to_fw"
#   resource_group_name = data.terraform_remote_state.netcore.outputs.aks_rg
#   route_table_name       = azurerm_route_table.aks_route_table.name
#   address_prefix         = data.terraform_remote_state.netcore.outputs.vnet_hub_appgw_subnet_address_space[0]
#   next_hop_type          = "VirtualAppliance"
#   next_hop_in_ip_address = data.terraform_remote_state.firewall.outputs.private_ip_address
# }

resource "azurerm_network_security_rule" "gateway_allow_gateway_manager_https_inbound" {
     name                        = "AllowGatewayManagerInbound"
     description                 = "Allow Azure application GatewayManager on management ports"
     resource_group_name         = data.terraform_remote_state.netcore.outputs.netcore_rg
     network_security_group_name = data.terraform_remote_state.netcore.outputs.appgw_subnet_nsg_name
     priority                    = 2510
     direction                   = "Inbound"
     access                      = "Allow"
     protocol                    = "Tcp"
     source_port_range           = "*"
     source_address_prefix       = "GatewayManager"
     destination_port_range      = "65200-65535"
     destination_address_prefix  = "*"
   }

resource "azurerm_subnet_route_table_association" "aks_route_table_node_subnet" {
  subnet_id      = azurerm_subnet.node_subnet.id
  route_table_id = azurerm_route_table.aks_route_table.id
  depends_on     = [azurerm_route_table.aks_route_table]
}

resource "azurerm_subnet_route_table_association" "aks_route_table_pod_subnet" {
  subnet_id      = azurerm_subnet.pod_subnet.id
  route_table_id = azurerm_route_table.aks_route_table.id
  depends_on     = [azurerm_route_table.aks_route_table]
}
resource "azurerm_network_security_group" "node_subnet_nsg" {
  name                = "vnet_aks_node_subnet_nsg"
  location            = var.location
  resource_group_name = data.terraform_remote_state.netcore.outputs.aks_rg
}

resource "azurerm_network_security_group" "pod_subnet_nsg" {
  name                = "vnet_aks_pod_subnet_nsg"
  location            = var.location
  resource_group_name = data.terraform_remote_state.netcore.outputs.aks_rg
}
resource "azurerm_subnet_network_security_group_association" "node_subnet_nsg" {
  subnet_id                 = azurerm_subnet.node_subnet.id
  network_security_group_id = azurerm_network_security_group.node_subnet_nsg.id
}
resource "azurerm_subnet_network_security_group_association" "pod_subnet_nsg" {
  subnet_id                 = azurerm_subnet.pod_subnet.id
  network_security_group_id = azurerm_network_security_group.pod_subnet_nsg.id
}