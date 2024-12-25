resource "azurerm_resource_group" "zitrg" {
  name     = var.azure_rg_name
  location = var.azure_location

  tags = local.tags

}

# Create virtual network

resource "azurerm_virtual_network" "zitvnet" {
  name                = var.virtual_network_name
  address_space       = ["10.30.0.0/16"]
  location            = azurerm_resource_group.zitrg.location
  resource_group_name = azurerm_resource_group.zitrg.name
  tags                = local.tags
}

# Create subnet

resource "azurerm_subnet" "zitsubnet" {
  name                 = var.virtual_subnet_name
  resource_group_name  = azurerm_resource_group.zitrg.name
  virtual_network_name = azurerm_virtual_network.zitvnet.name
  address_prefixes     = ["10.30.1.0/24"]

}

# Create public IP
resource "azurerm_public_ip" "zitpip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.zitrg.location
  resource_group_name = azurerm_resource_group.zitrg.name
  allocation_method   = "Static"

  tags = local.tags

}


# Create network Security Group

resource "azurerm_network_security_group" "zitnsg" {
  name                = var.network_security_group_name
  location            = azurerm_resource_group.zitrg.location
  resource_group_name = azurerm_resource_group.zitrg.name
  tags                = local.tags
}


# Create network Security Group rule

resource "azurerm_network_security_rule" "zitnsgrule" {
  name                        = "AllowHTTP"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.zitrg.name
  network_security_group_name = azurerm_network_security_group.zitnsg.name

}


# Cretae network interface 

resource "azurerm_network_interface" "zitnic" {

  name                = var.network_nic_name
  location            = azurerm_resource_group.zitrg.location
  resource_group_name = azurerm_resource_group.zitrg.name

  ip_configuration {
    name                          = "twnicipconfiguration"
    subnet_id                     = azurerm_subnet.zitsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.zitpip.id
  }

}

# Connect 

resource "azurerm_network_interface_security_group_association" "zitnicnsg" {

  network_interface_id      = azurerm_network_interface.zitnic.id
  network_security_group_id = azurerm_network_security_group.zitnsg.id


}

# Generate random name 

resource "random_id" "random_id" {
  keepers = {

    resource_group = azurerm_resource_group.zitrg.name
  }
  byte_length = 8

}

resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true

}

resource "random_pet" "prefix" {
  prefix = var.prefix
  length = 1
}

#Create storage account

resource "azurerm_storage_account" "zitsta" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.zitrg.location
  resource_group_name      = azurerm_resource_group.zitrg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"


}

# Create virtual machine

resource "azurerm_windows_virtual_machine" "zitwebserver" {
  name                  = "${var.prefix}-vm"
  admin_username        = "sysadmin"
  admin_password        = random_password.password.result
  location              = azurerm_resource_group.zitrg.location
  resource_group_name   = azurerm_resource_group.zitrg.name
  network_interface_ids = [azurerm_network_interface.zitnic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "zitosdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.zitsta.primary_blob_endpoint
  }

}

# Install IIS virtual machine extension

resource "azurerm_virtual_machine_extension" "web_server_install" {
  name                       = "${random_pet.prefix.id}-wsi"
  virtual_machine_id         = azurerm_windows_virtual_machine.zitwebserver.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
    "commandToExecute" : "powershell Set-ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }

SETTINGS

}

