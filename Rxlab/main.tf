provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id = var.tenant_id
  client_secret = var.client_secret
  client_id = var.client_id
  features {}
}

data "azurerm_image" "search" {
  name                = var.image_name
  resource_group_name = var.resources_predefined_rg
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_windows_virtual_machine_scale_set" "main" {
  name                = "${var.prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard_F2"
  instances           = 2
  admin_password      = "P@ssw0rd1234!"
  admin_username      = "adminuser"
  upgrade_mode = "Automatic"
  source_image_id     = data.azurerm_image.search.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  data_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    lun           = 1
    disk_size_gb  = 4
  }

  network_interface {
    name    = "windowsterraformnetworkprofile"
    primary = true

    ip_configuration {
      name      = "WindowsIPConfiguration"
      primary   = true
      subnet_id = var.subnet_id
      public_ip_address {
        name  = "${var.prefix}ip"
        idle_timeout_in_minutes = 15
      }
    }
  }
}

output "name" {
  value = azurerm_windows_virtual_machine_scale_set.main.name
}

output "operating_system" {
  value = "Windows"
}

output "scaleset" {
  value = "True"
}
