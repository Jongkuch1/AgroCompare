# Owner: Jongkuch1 (Summative Part 1: network, bastion, private VM, load balancer)
# The bastion (jump box) is the only machine with SSH reachable from outside.
# Ansible and humans reach the private app VM by hopping through it.

resource "azurerm_public_ip" "bastion" {
  name                = "${local.name_prefix}-bastion-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "bastion" {
  # Accepted risk: a bastion has to be reachable from outside. The NSG allows
  # SSH from one address only. See SECURITY.md.
  #checkov:skip=CKV_AZURE_119:A bastion needs a public IP; SSH is limited to one address by the NSG

  name                = "${local.name_prefix}-bastion-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion.id
  }
}

resource "azurerm_linux_virtual_machine" "bastion" {
  name                = "${local.name_prefix}-bastion"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.bastion_vm_size
  admin_username      = var.admin_username
  tags                = local.common_tags

  network_interface_ids = [azurerm_network_interface.bastion.id]

  disable_password_authentication = true
  allow_extension_operations      = false

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
