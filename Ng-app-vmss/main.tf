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

resource "azurerm_network_security_group" "vmss" {
  name     = "${var.prefix}-nsg"
  location = var.location
  resource_group_name = "${var.prefix}-resources"

  security_rule {
    name = "port_${var.application_port}"
    direction = "Inbound"
    access = "Allow"
    priority = "100"
    source_address_prefix = "*"
    source_port_range = "*"
    destination_address_prefix = "*"
    destination_port_range = var.application_port
    protocol = "TCP"
  }

}

resource "azurerm_public_ip" "vmss" {
  name                         = "${var.prefix}-public-ip"
  location                     = var.location
  resource_group_name          = "${var.prefix}-resources"
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_lb" "vmss" {
  name                = "${var.prefix}-lb"
  location            = var.location
  resource_group_name = "${var.prefix}-resources"
  sku = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vmss.id
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = "${var.prefix}-resources"
  loadbalancer_id     = azurerm_lb.vmss.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "vmss" {
  resource_group_name = "${var.prefix}-resources"
  loadbalancer_id     = azurerm_lb.vmss.id
  name                = "ssh-running-probe"
  port                = var.application_port
}

resource "azurerm_lb_rule" "lbnatrule" {
  resource_group_name            = "${var.prefix}-resources"
  loadbalancer_id                = azurerm_lb.vmss.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.vmss.id
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.prefix}-vm"
  location            = var.location
  resource_group_name = "${var.prefix}-resources"
  sku                 = "Standard_A0"
  instances           = 2
  admin_username       = "adminuser"
  admin_password       = "password@123"
  disable_password_authentication = false

  source_image_id = data.azurerm_image.search.id

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

  network_interface {
    name    = "terraformnetworkprofile"
    primary = true
    network_security_group_id = azurerm_network_security_group.vmss.id
    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      primary = true
    }
  }
}

output "name" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.name
}

output "lb_ip_address" {
  value = azurerm_public_ip.vmss.name
}

output "operating_system" {
  value = "Linux"
}

output "scaleset" {
  value = "True"
}