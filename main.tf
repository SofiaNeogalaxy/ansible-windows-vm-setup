locals {
  target_resource_group  = format("%s-%s-%s-%03d", var.resource_group_prefix, var.purpose, var.environment_name, var.instance_id)
  target_storage_account = format("%s%s%s%03d", var.storage_account_prefix, var.purpose, var.environment_name, var.instance_id)
}

resource "azurerm_resource_group" "win_rg" {
  name     = local.target_resource_group
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "win_rg" {
  name                = "win_rg-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.win_rg.location
  resource_group_name = azurerm_resource_group.win_rg.name
}

resource "azurerm_subnet" "win_rg" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.win_rg.name
  virtual_network_name = azurerm_virtual_network.win_rg.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "win_rg_ni" {
  name                = "win_rg-nic"
  location            = azurerm_resource_group.win_rg.location
  resource_group_name = azurerm_resource_group.win_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.win_rg.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.win_public_ip.id
  }
}

resource "azurerm_storage_account" "my_storage_account" {
  name                     = local.target_storage_account
  location                 = azurerm_resource_group.win_rg.location
  resource_group_name      = azurerm_resource_group.win_rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create public IPs
resource "azurerm_public_ip" "win_public_ip" {
  name                = "win_public_ip"
  location            = azurerm_resource_group.win_rg.location
  resource_group_name = azurerm_resource_group.win_rg.name
  allocation_method   = "Static"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "win_nsg" {
  name                = "NetworkSG1"
  location            = azurerm_resource_group.win_rg.location
  resource_group_name = azurerm_resource_group.win_rg.name

  security_rule {
    name                       = "WIN SR"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                        = "WINRM-HTTP"
    priority                    = 101
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "5985-5986"
    source_address_prefix       = "*"
    destination_address_prefix  = "VirtualNetwork"
  }
}

resource "azurerm_network_interface_security_group_association" "nis_association" {
  network_interface_id      = azurerm_network_interface.win_rg_ni.id
  network_security_group_id = azurerm_network_security_group.win_nsg.id
}

resource "azurerm_windows_virtual_machine" "win_vm" {
  name                = "win-vm-machine"
  resource_group_name = azurerm_resource_group.win_rg.name
  location            = azurerm_resource_group.win_rg.location
  size                = "Standard_A2_V2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.win_rg_ni.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }

  winrm_listener {
    protocol = "Http"
  }

}

