locals {
  acr_data_ip    = lookup(azurerm_private_endpoint.acr_private_endpoint.private_service_connection[0], "private_ip_address", "what")

  split_ip       = split(".", lookup(azurerm_private_endpoint.acr_private_endpoint.private_service_connection[0], "private_ip_address", "what"))
  
  acr_ip = join(".", tolist([local.split_ip[0], local.split_ip[1], local.split_ip[2], local.split_ip[3] + 1]))
}