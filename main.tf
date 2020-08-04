provider "azurerm" {
  features {}
}

locals {
  env = terraform.workspace

  counts = {
    "dev" = 1
    "prod"  = 2
  }

  locations = {
    "dev" = "uksouth"
    "prod"  = "westeurope"
  }

  count    = "${lookup(local.counts, local.env)}"
  location = "${lookup(local.locations, local.env)}"
}

resource "azurerm_resource_group" "workspaces_rg" {
  name     = "${local.env}-rg"
  location = local.location
}

resource "azurerm_virtual_network" "workspaces_vnet" {
  name                = "${local.env}-vnet"
  resource_group_name = azurerm_resource_group.workspaces_rg.name
  location            = azurerm_resource_group.workspaces_rg.location
  address_space       = ["10.0.0.0/22"]
}

resource "azurerm_subnet" "workspaces_subnet" {
  name                 = "${local.env}-subnet"
  resource_group_name  = azurerm_resource_group.workspaces_rg.name
  virtual_network_name = azurerm_virtual_network.workspaces_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

}

resource "azurerm_network_interface" "vm_interface" {
  name                = "${local.env}-${format("%02d", count.index + 1)}-vm-int"
  resource_group_name = azurerm_resource_group.workspaces_rg.name
  location            = azurerm_resource_group.workspaces_rg.location
  count               = local.count

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.workspaces_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

}
resource "azurerm_windows_virtual_machine" "main_vm" {
  name                     = "${local.env}-${format("%02d", count.index + 1)}-vm"
  resource_group_name      = azurerm_resource_group.workspaces_rg.name
  location                 = azurerm_resource_group.workspaces_rg.location
  size                     = "Standard_B2s"
  admin_username           = "sysadmin"
  admin_password           = "password_123"
  provision_vm_agent       = true
  enable_automatic_updates = true
  count                    = local.count

  network_interface_ids = [
    azurerm_network_interface.vm_interface[count.index].id
  ]

  os_disk {
    name                 = "${local.env}-${format("%02d", count.index + 1)}-vm-disk"
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

