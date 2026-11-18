# Owner: Jongkuch1 (Summative Part 1: network, bastion, private VM, load balancer)
# The app server. It sits in the private subnet and has NO public IP.
# Web traffic reaches it through the load balancer (loadbalancer.tf);
# SSH reaches it only through the bastion.

resource "azurerm_network_interface" "app" {
  name                = "${local.name_prefix}-app-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "app" {
  name                = "${local.name_prefix}-app-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.app_vm_size
  admin_username      = var.admin_username
  tags                = local.common_tags

  network_interface_ids = [azurerm_network_interface.app.id]

  # SSH keys only: password login is switched off
  disable_password_authentication = true

  # Ansible configures the VM over SSH, not Azure VM extensions
  allow_extension_operations = false

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
