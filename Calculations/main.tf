provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id = var.tenant_id
  client_secret = var.client_secret
  client_id = var.client_id
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

data "azurerm_image" "search" {
  name                = var.image_name
  resource_group_name = var.resources_predefined_rg
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_windows_virtual_machine" "main" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_B1MS"
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!"
  source_image_id                 =  data.azurerm_image.search.id
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

resource "azurerm_managed_disk" "example" {
  name                 = "${var.prefix}-disk1"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 5
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.example.id
  virtual_machine_id = azurerm_windows_virtual_machine.main.id
  lun                = "1"
  caching            = "ReadWrite"
}

output "name" {
  value = azurerm_windows_virtual_machine.main.name
}

output "public_ip" {
  value = azurerm_windows_virtual_machine.main.public_ip_address
}

output "operating_system" {
  value = "Windows"
}

output "scaleset" {
  value = "False"
}
