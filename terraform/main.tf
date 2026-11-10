locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      project     = var.project_name
      environment = var.environment
      managed_by  = "terraform"
    },
    var.tags
  )
}

# ---------- Resource group ----------
resource "azurerm_resource_group" "main" {
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

# ---------- Network: virtual network + subnet ----------
resource "azurerm_virtual_network" "main" {
  name                = "${local.name_prefix}-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "app" {
  name                 = "${local.name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_prefix]
}

# ---------- Network security group (firewall rules) ----------
# Azure already denies all other inbound traffic by default, so only the
# two rules we need are opened.
resource "azurerm_network_security_group" "app" {
  name                = "${local.name_prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  security_rule {
    name                       = "allow-ssh-from-my-ip"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_ip_cidr
    destination_address_prefix = "*"
  }

  # One rule per extra teammate IP, so each person's access is visible and
  # independently revocable instead of being merged into one wide rule.
  dynamic "security_rule" {
    for_each = { for idx, cidr in var.team_ssh_cidrs : idx => cidr }
    content {
      name                       = "allow-ssh-team-${security_rule.key}"
      priority                   = 101 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
    }
  }

  security_rule {
    name                       = "allow-app-http"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.app_port)
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

# ---------- Public IP + network interface ----------
resource "azurerm_public_ip" "vm" {
  name                = "${local.name_prefix}-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "vm" {
  # Accepted risk: the web app must be reachable from the internet, so this
  # NIC has a public IP. The NSG limits SSH to one address and opens only the
  # app port. See SECURITY.md.
  #checkov:skip=CKV_AZURE_119:Public IP is required to serve the web app; exposure limited by the NSG

  name                = "${local.name_prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

# ---------- Compute: Ubuntu 22.04 VM ----------
resource "azurerm_linux_virtual_machine" "app" {
  name                = "${local.name_prefix}-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = local.common_tags

  network_interface_ids = [azurerm_network_interface.vm.id]

  # SSH keys only: password login is switched off
  disable_password_authentication = true

  # We configure the VM with Ansible over SSH, not with Azure VM extensions,
  # so extension operations are switched off (fewer ways in).
  allow_extension_operations = false

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  dynamic "admin_ssh_key" {
    for_each = var.additional_ssh_public_key_paths
    content {
      username   = var.admin_username
      public_key = file(pathexpand(admin_ssh_key.value))
    }
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
