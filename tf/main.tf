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
    public_key = ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCPzlJmJSeMzPeap7RuKR1JAXS3TZNvT7jUMqacMGjW2Mis5yqYwxmoJ67k0UF3XoAYmlI7nIQU5gRuan2XS3/4ektnQ3hlni3qZ6MaBeTJkVKb8M01cl/QqMx8x2SnMHu4mF9D9BuH4WEgIhMjZzKeTfL/gaeDNkdHN8NFjP2c1arJNvwb/ew6/jvlFCzT9jAiV3HUlPYqpIjKsigYQXPFWjLlXugozHgQ0g0n/CvyIl04d9Xe1P4Y0q4jcQ8tcTQUiX8LdPkkUANulBihyIaQZW6jzb9PAUHwbNUcXlYjqywOk0Z5CRU9kDqW4jKmMuYcKrhBRcaTObqd/XAnC+Yzgcdsnv2+rCSzc+RwRJQdELG1gke/N48YcyhJ5j0Hp8kLeYYEDzYP6gKeh8+JEuqKuCJ1GWjXgYJKoEwmRyYDWROgajwoJhoCsPY/xourXeipXDnAy/1RV7+wJPlgbY2/pNMCgpIieStV0pkS8VJQAEKnSp1iqk4oDit6ik/tiUj5OjbJr4rxwuuof3wDrKqpwIOSkf7BckzFOzIzE7bzrYFRfBtQBzCGoDOz9kexQil/SX4N0SqoSoVMbHEKqJwECZjivZTk4NLadFZ5Q30w/Xe61zfvHKz6ByUyWwSBtI395qi8RiCyQcJYnMSMoNQycrj+JyNIqhlnPKDUP8MR+w== luis@SandboxHost-638839735151658856
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
