provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id = var.tenant_id
  client_secret = var.client_secret
  client_id = var.client_id
  features {}
}

resource "azurerm_network_security_group" "vmss" {
  name     = "${var.prefix}-nsg"
  location = "East US"
  resource_group_name = "director-cp"
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.prefix}-vm"
  location            = var.location
  resource_group_name = "director-cp"
  sku                 = "Standard_F2"
  instances           = 2
  admin_username       = "adminuser"
  admin_password       = "password@123"
  disable_password_authentication = false

  source_image_id = var.image_id

  os_disk {
      storage_account_type = "Standard_LRS"
      caching              = "ReadWrite"
    }
  
    data_disk {
      storage_account_type = "Standard_LRS"
      caching              = "ReadWrite"
      lun           = 0
      disk_size_gb  = 10
    }

    data_disk {
      storage_account_type = "Standard_LRS"
      caching              = "ReadWrite"
      lun           = 1
      disk_size_gb  = 2
    }

  network_interface {
    name    = "terraformnetworkprofile"
    primary = true
    network_security_group_id = azurerm_network_security_group.vmss.id
    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = "/subscriptions/e6139af9-7952-444a-bef0-82110bcd6db5/resourceGroups/director-cp/providers/Microsoft.Network/virtualNetworks/director-cp-vnet/subnets/default"
      //load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      primary = true
    }
  }
}

output "name" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.name
}

output "operating_system" {
  value = "Linux"
}

output "scaleset" {
  value = "True"
}