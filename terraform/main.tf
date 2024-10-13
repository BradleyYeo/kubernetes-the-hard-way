# Define the virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "debian-vm-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Define the subnet
resource "azurerm_subnet" "subnet" {
  name                 = "debian-vm-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define the network security group
resource "azurerm_network_security_group" "nsg" {
  name                = "debian-vm-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a network interface for each VM
resource "azurerm_network_interface" "jumpbox_nic" {
  name                = "jumpbox-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "jumpbox-nic-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "server_nic" {
  name                = "server-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "server-nic-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "node_0_nic" {
  name                = "node-0-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "node-0-nic-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "node_1_nic" {
  name                = "node-1-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "node-1-nic-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a virtual machine for the jumpbox (administration host)
resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                = "jumpbox"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.jumpbox_nic.id]
  size                = "Standard_A1_v2"  # 1 CPU, 512MB RAM

  admin_username      = "adminuser"
  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.linux-key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 10  # 10GB storage
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12-arm64"
    sku       = "12-arm64-gen2"
    version   = "latest"
  }
}

# Create a virtual machine for the Kubernetes server
resource "azurerm_linux_virtual_machine" "server" {
  name                = "k8s-server"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.server_nic.id]
  size                = "Standard_A1_v2"  # 1 CPU, 2GB RAM

  admin_username      = "adminuser"
  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.linux-key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 20  # 20GB storage
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12-arm64"
    sku       = "12-arm64-gen2"
    version   = "latest"
  }
}

# Create a virtual machine for the first Kubernetes worker node (node-0)
resource "azurerm_linux_virtual_machine" "node_0" {
  name                = "k8s-node-0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.node_0_nic.id]
  size                = "Standard_A1_v2"  # 1 CPU, 2GB RAM

  admin_username      = "adminuser"
  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.linux-key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 20  # 20GB storage
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12-arm64"
    sku       = "12-arm64-gen2"
    version   = "latest"
  }
}

# Create a virtual machine for the second Kubernetes worker node (node-1)
resource "azurerm_linux_virtual_machine" "node_1" {
  name                = "k8s-node-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.node_1_nic.id]
  size                = "Standard_A1_v2"  # 1 CPU, 2GB RAM

  admin_username      = "adminuser"
  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.linux-key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 20  # 20GB storage
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12-arm64"
    sku       = "12-arm64-gen2"
    version   = "latest"
  }
}

resource "tls_private_key" "linux-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}