resource "azurerm_public_ip" "dns_public_ip" {
  name                = "dns_server_public_ip"
  resource_group_name = azurerm_resource_group.netcore_rg.name
  location            = var.location
  allocation_method   = "Dynamic"

}

resource "azurerm_network_interface" "dns_nic" {
  name                = "dns_nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.netcore_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.dns_server_ip
    public_ip_address_id          = azurerm_public_ip.dns_public_ip.id
  }

  depends_on = [azurerm_public_ip.dns_public_ip]
}

resource "azurerm_linux_virtual_machine" "dns_server" {
  name                            = "sme-${var.alias}-dns"
  resource_group_name             = azurerm_resource_group.netcore_rg.name
  location                        = var.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "dns_user"
  admin_password                  = "roadtoSEE!"
  disable_password_authentication = "false"

  network_interface_ids = [
    azurerm_network_interface.dns_nic.id,
  ]

  custom_data = filebase64("dns_script.sh")

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  depends_on = [azurerm_network_interface.dns_nic]
}