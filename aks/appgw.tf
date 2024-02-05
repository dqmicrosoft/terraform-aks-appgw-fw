resource "azurerm_public_ip" "appgw_public_ip" {
  name                = "appgw_public_ip"
  resource_group_name = data.terraform_remote_state.netcore.outputs.netcore_rg
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "sme_${var.alias}_appgw"
  resource_group_name = data.terraform_remote_state.netcore.outputs.netcore_rg
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "ip_appgw_aks"
    subnet_id = data.terraform_remote_state.netcore.outputs.vnet_hub_appgw_subnet_id
  }

  frontend_port {
    name = "frontend_port_appgw_aks"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "public_frontend_ip_appgw_aks"
    public_ip_address_id = azurerm_public_ip.appgw_public_ip.id
  }

  frontend_ip_configuration {
    name                          = "private_frontend_ip_appgw_aks"
    private_ip_address            = var.appgw_private_ip
    private_ip_address_allocation = "Static"
    subnet_id                     = data.terraform_remote_state.netcore.outputs.vnet_hub_appgw_subnet_id
  }

  backend_address_pool {
    name = "backend_appgw_aks"
  }

  backend_http_settings {
    name                  = "backend_http_appgw_aks"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http_listener_appgw_aks"
    frontend_ip_configuration_name = "public_frontend_ip_appgw_aks"
    frontend_port_name             = "frontend_port_appgw_aks"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "request_routing_rule_appgw_aks"
    rule_type                  = "Basic"
    http_listener_name         = "http_listener_appgw_aks"
    backend_address_pool_name  = "backend_appgw_aks"
    backend_http_settings_name = "backend_http_appgw_aks"
    priority                   = 1
  }

  #ignore changes since AGW is managed by AGIC
  lifecycle {
    ignore_changes = [
      tags,
      backend_address_pool,
      backend_http_settings,
      frontend_port,
      http_listener,
      probe,
      redirect_configuration,
      request_routing_rule,
      ssl_certificate
    ]
  }
  depends_on = [ azurerm_network_security_rule.gateway_allow_gateway_manager_https_inbound ]
}

# resource "azurerm_firewall_nat_rule_collection" "fw_dnat_to_appgw_private_ip" {
#   name                = "fw_dnat_to_appgw_private_ip"
#   azure_firewall_name = data.terraform_remote_state.firewall.outputs.fw_name
#   resource_group_name = data.terraform_remote_state.netcore.outputs.netcore_rg
#   priority            = 100
#   action              = "Dnat"

#   rule {
#     name = "agic_http"

#     source_addresses = [
#       "*",
#     ]

#     destination_ports = [
#       "80",
#     ]

#     destination_addresses = [data.terraform_remote_state.firewall.outputs.public_ip_address]


#     translated_port = 80

#     translated_address = var.appgw_private_ip

#     protocols = [
#       "TCP",
#     ]
#   }
# }