provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "webapp-rg"
  location = "East US 2"
}


resource "azurerm_public_ip" "pip" {
  name                = "prueba-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
}


resource "azurerm_virtual_network" "vnet" {
  name                = "prueba-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "prueba-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_network_interface" "nic" {
  name                = "prueba-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "prueba-vm"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = "Standard_B1s"
  admin_username        = "wollmanhoyos"
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "wollmanhoyos"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_static_site" "frontend" {
  name                = "loginejemplo"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku_name            = "Free"

  app_location       = "../webapp"
  output_location    = "../webapp"
  index_document     = "index.html"
  error_404_document = "index.html"
}


output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}
