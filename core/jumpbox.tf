resource "azurerm_public_ip" "jump_public_ip" {
  name                = "jump_box_public_ip"
  resource_group_name = data.terraform_remote_state.netcore.outputs.core_rg
  location            = var.location
  allocation_method   = "Static"

}

resource "azurerm_network_interface" "jump_nic" {
  name                = "jump_nic"
  location            = var.location
  resource_group_name = data.terraform_remote_state.netcore.outputs.core_rg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.netcore.outputs.vnet_hub_hub_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jump_public_ip.id
  }

  depends_on = [azurerm_public_ip.jump_public_ip]
}

resource "azurerm_linux_virtual_machine" "jump_box" {
  name                            = "sme-${var.alias}-jump-box"
  resource_group_name             = data.terraform_remote_state.netcore.outputs.core_rg
  location                        = var.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "jump_user"
  admin_password                  = "roadtoSEE!"
  disable_password_authentication = "false"

  network_interface_ids = [
    azurerm_network_interface.jump_nic.id,
  ]
  
  custom_data = filebase64("jump_script.sh")

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
  depends_on = [azurerm_network_interface.jump_nic]
}