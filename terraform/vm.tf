resource "azurerm_virtual_network" "cp2" {
  name                = "vnet-casopractico2"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.cp2.location
  resource_group_name = azurerm_resource_group.cp2.name
}

resource "azurerm_subnet" "cp2" {
  name                 = "snet-casopractico2"
  resource_group_name  = azurerm_resource_group.cp2.name
  virtual_network_name = azurerm_virtual_network.cp2.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_security_group" "cp2_vm" {
  name                = "nsg-casopractico2-vm"
  location            = azurerm_resource_group.cp2.location
  resource_group_name = azurerm_resource_group.cp2.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "cp2_vm" {
  name                = "pip-casopractico2-vm"
  location            = azurerm_resource_group.cp2.location
  resource_group_name = azurerm_resource_group.cp2.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "cp2_vm" {
  name                = "nic-casopractico2-vm"
  location            = azurerm_resource_group.cp2.location
  resource_group_name = azurerm_resource_group.cp2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cp2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.cp2_vm.id
  }
}

resource "azurerm_network_interface_security_group_association" "cp2_vm" {
  network_interface_id      = azurerm_network_interface.cp2_vm.id
  network_security_group_id = azurerm_network_security_group.cp2_vm.id
}

resource "azurerm_linux_virtual_machine" "cp2_vm" {
  name                            = "vm-casopractico2"
  location                        = azurerm_resource_group.cp2.location
  resource_group_name             = azurerm_resource_group.cp2.name
  size                            = var.vm_size
  admin_username                  = var.ssh_user
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.cp2_vm.id]

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "cognosys"
    offer     = "centos-8-stream-free"
    sku       = "centos-8-stream-free"
    version   = "22.03.28"
  }

  plan {
    name      = "centos-8-stream-free"
    publisher = "cognosys"
    product   = "centos-8-stream-free"
  }
}
