resource "azurerm_virtual_network" "virtual_network" {
  address_space       = ["10.0.0.0/16"]
  location            = var.region
  name                = "odm_virtual_network"
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  name                 = "odm_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes = ["10.0.1.0/24"]
  depends_on = [ azurerm_virtual_network.virtual_network ]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "odm_public_ip"
  resource_group_name = var.resource_group_name
  location            = var.region
  allocation_method   = "Static"
  lifecycle {
    create_before_destroy = true
  }

  tags = var.project_tags
}

resource "azurerm_network_interface" "nic" {
  location            = var.region
  name                = "odm_nic"
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "odm_configuration"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
  depends_on = [ azurerm_public_ip.public_ip, azurerm_subnet.subnet ]
}

resource "azurerm_virtual_machine" "vm" {
  location              = var.region
  name                  = "odm_vm"
  network_interface_ids = [azurerm_network_interface.nic.id]
  resource_group_name   = var.resource_group_name
  vm_size               = "Standard_A1_v2"
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination = true
  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "odmplatform"
    admin_username = "odm"
    admin_password = "0p3nD@t@M3sh"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = var.project_tags
  depends_on = [ azurerm_network_interface.nic ]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "odm_nsg"
  location            = var.region
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow_ssh"
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
    name                       = "allow_odm_platform_ui"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8001"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_odm_devops_ui"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8002"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_odm_exe_azdevops_ui"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9003"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [ azurerm_virtual_machine.vm ]
}

resource "azurerm_network_interface_security_group_association" "sg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [ azurerm_virtual_machine.vm ]
}