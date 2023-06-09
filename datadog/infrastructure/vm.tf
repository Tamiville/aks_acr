resource "azurerm_resource_group" "elite_general_rg" {
  name     = var.elite_general_rg
  location = var.location
}

resource "azurerm_network_interface" "labnic" {
  name                = join("-", [local.server, "lab", "nic"])
  location            = local.buildregion
  resource_group_name = azurerm_resource_group.elite_general_rg.name

  ip_configuration {
    name                          = var.ip_configuration_name
    subnet_id                     = azurerm_subnet.application_subnet.id
    private_ip_address_allocation = var.private_ip_address_allocation
    public_ip_address_id          = azurerm_public_ip.labpip.id
  }
}

resource "azurerm_public_ip" "labpip" {
  name                = join("-", [local.server, "lab", "pip"])
  resource_group_name = azurerm_resource_group.elite_general_rg.name
  location            = local.buildregion
  allocation_method   = var.allocation_method

  tags = local.common_tags
}


resource "azurerm_linux_virtual_machine" "Linuxvm" {
  name                = join("-", [local.server, "linux", "vm"])
  resource_group_name = azurerm_resource_group.elite_general_rg.name
  location            = local.buildregion
  size                = "Standard_DS1_v2"
  admin_username      = var.user
  network_interface_ids = [
    azurerm_network_interface.labnic.id,
  ]

  connection {
    type        = "ssh"
    user        = var.user
    private_key = file(var.path_privatekey)
    host        = self.public_ip_address
  }

  admin_ssh_key {
    username   = var.user
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD66xeXBmNTNc/hftCmTCLe9jS0VKY2Lg/IXZAdKVWnrXJBjBUnwxoW6QZ8wPpgoUgIebbUqtF+Dodu8S81qANBRVP9k9jTHQJUFAgybgOsEpFVW3x8G1X5tqoyIYIj7GvFSXrME3K7rK6kH1t2sIZz8wpCJ6tlUIt8JushDHxSf38/v/rfAfa/xUnYKdjVx/gj3FQvMGa+5zPzjeRk+826Tthfo17VT9tbAxh3r7uk3xV41KqfZkGeTB+tbPfO/9R2apyblmvjnvs8s2c8fhN0fnEZqRklxhmGUzUtQVwBAfgt97jffLkHSGVyj5L/uPr3+6F0oRXUGtyvxyf20ct1 devopslab@Tamie-Emmanuel"
  }


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer     = "0001-com-ubuntu-server-focal"
    publisher = "Canonical"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}