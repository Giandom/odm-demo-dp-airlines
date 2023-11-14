resource "azurerm_virtual_network" "demo_virtual_network" {
  address_space       = ["10.0.0.0/16"]
  location            = var.region
  name                = "demo_virtual_network"
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "demo_subnet" {
  name                 = "demo_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.demo_virtual_network.name
  address_prefixes = ["10.0.1.0/24"]
  depends_on = [ azurerm_virtual_network.demo_virtual_network ]
}

resource "azurerm_public_ip" "airline" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = var.resource_group_name
  location            = var.region
  allocation_method   = "Static"
  lifecycle {
    create_before_destroy = true
  }

  tags = var.project_tags
}

resource "azurerm_network_interface" "demo_nic" {
  location            = var.region
  name                = "demo_nic"
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "demo_configuration"
    subnet_id = azurerm_subnet.demo_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.airline.id
  }
  depends_on = [ azurerm_subnet.demo_subnet, azurerm_public_ip.airline ]
}

resource "azurerm_virtual_machine" "demo_vm" {
  location              = var.region
  name                  = "demo_vm"
  network_interface_ids = [azurerm_network_interface.demo_nic.id]
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
    name              = "demo_vm_disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "odmairlinedemo"
    admin_username = "airline"
    admin_password = "@1rl1n3D3m0!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = var.project_tags
  depends_on = [ azurerm_network_interface.demo_nic ]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "ssh_nsg"
  location            = var.region
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow_ssh_sg"
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
    name                       = "allow_web_sg"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [ azurerm_virtual_machine.demo_vm ]
}

resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.demo_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [ azurerm_virtual_machine.demo_vm ]
}