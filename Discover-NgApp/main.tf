# azurerm_linux_virtual_machine.main:
resource "azurerm_linux_virtual_machine" "main" {
    admin_username                  = "adminuser"
    allow_extension_operations      = true
    computer_name                   = "Discover-Pack-Test-vm"
    disable_password_authentication = false
    encryption_at_host_enabled      = false
    location                        = "eastus"
    max_bid_price                   = -1
    name                            = "Discover-Pack-Test-vm"
    network_interface_ids           = [ azurerm_network_interface.main.id ]
    priority                        = "Regular"
    provision_vm_agent              = true
    resource_group_name             = azurerm_resource_group.main.name
    size                            = "Standard_F1"
    source_image_id                 = "/subscriptions/e6139af9-7952-444a-bef0-82110bcd6db5/resourceGroups/director-cp/providers/Microsoft.Compute/images/demo-centos-image-11-09-2020"

    os_disk {
        caching                   = "ReadWrite"
        disk_size_gb              = 31
        name                      = "Discover-Pack-Test-vm_disk1_e6ff8a5849e642cd8b25942c721c9e56"
        storage_account_type      = "Standard_LRS"
        write_accelerator_enabled = false
    }
}

# azurerm_managed_disk.example:
resource "azurerm_managed_disk" "example" {
    create_option        = "Empty"
    disk_iops_read_write = 500
    disk_mbps_read_write = 60
    disk_size_gb         = 5
    location             = "eastus"
    name                 = "Discover-Pack-Test-disk1"
    resource_group_name  = azurerm_resource_group.main.name
    storage_account_type = "Standard_LRS"
}

# azurerm_network_interface.main:
resource "azurerm_network_interface" "main" {
    dns_servers                   = []
    enable_accelerated_networking = false
    enable_ip_forwarding          = false
    location                      = "eastus"
    name                          = "Discover-Pack-Test-nic"
    resource_group_name           = azurerm_resource_group.main.name

    ip_configuration {
        name                          = "internal"
        primary                       = true
        private_ip_address            = "10.0.2.4"
        private_ip_address_allocation = "Dynamic"
        private_ip_address_version    = "IPv4"
        public_ip_address_id          = azurerm_public_ip.main.id
        subnet_id                     = azurerm_subnet.internal.id
    }
}

# azurerm_public_ip.main:
resource "azurerm_public_ip" "main" {
    allocation_method       = "Static"
    idle_timeout_in_minutes = 4
    ip_version              = "IPv4"
    location                = "eastus"
    name                    = "Discover-Pack-Test-pip"
    resource_group_name     = azurerm_resource_group.main.name
    sku                     = "Basic"
}

# azurerm_resource_group.main:
resource "azurerm_resource_group" "main" {
    location = "eastus"
    name     = "Discover-Pack-Test-resources"
}

# azurerm_subnet.internal:
resource "azurerm_subnet" "internal" {
    address_prefixes                               = [
        "10.0.2.0/24",
    ]
    enforce_private_link_endpoint_network_policies = false
    enforce_private_link_service_network_policies  = false
    name                                           = "internal"
    resource_group_name                            = azurerm_resource_group.main.name
    virtual_network_name                           = azurerm_virtual_network.main.name
}

# azurerm_virtual_machine_data_disk_attachment.example:
resource "azurerm_virtual_machine_data_disk_attachment" "example" {
    caching                   = "ReadWrite"
    create_option             = "Attach"
    lun                       = 1
    managed_disk_id           = azurerm_managed_disk.example.id
    virtual_machine_id        = azurerm_linux_virtual_machine.main.id
    write_accelerator_enabled = false
}

# azurerm_virtual_network.main:
resource "azurerm_virtual_network" "main" {
    address_space       = [
        "10.0.0.0/16",
    ]
    location            = "eastus"
    name                = "Discover-Pack-Test-network"
    resource_group_name = azurerm_resource_group.main.name
}

output "name" {
  value = azurerm_linux_virtual_machine.main.name
}

output "public_ip" {
  value = azurerm_linux_virtual_machine.main.public_ip_address
}

output "disk_size_in_gb" {
  value = azurerm_managed_disk.example.disk_size_gb
}

