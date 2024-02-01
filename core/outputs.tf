
output "acr_name" {
  value =  azurerm_container_registry.acr.name
}
output "acr_id" {
  value =  azurerm_container_registry.acr.id
}
output "msi_name" {
  value =  azurerm_user_assigned_identity.aks_uami.name
}
output "msi_id" {
  value =  azurerm_user_assigned_identity.aks_uami.id
}
output "msi_client_id" {
  value =  azurerm_user_assigned_identity.aks_uami.client_id
}
output "msi_principal_id" {
  value =  azurerm_user_assigned_identity.aks_uami.principal_id
}
output "jump_box_public_ip" {
  value =  azurerm_linux_virtual_machine.jump_box.public_ip_address
}
