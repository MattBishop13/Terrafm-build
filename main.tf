provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rgp" {
  name     = var.rg_name
  location = var.local
}

resource "azurerm_virtual_network" "vnet" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rgp.location
  resource_group_name = azurerm_resource_group.rgp.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rgp.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "MattsNic" {
  name                = "example-nic"
  location            = azurerm_resource_group.rgp.location
  resource_group_name = azurerm_resource_group.rgp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.rgp.name
  location            = azurerm_resource_group.rgp.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "Password12345"
  network_interface_ids = [
    azurerm_network_interface.MattsNic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}