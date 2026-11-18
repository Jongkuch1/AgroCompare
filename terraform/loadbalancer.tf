# Owner: Jongkuch1 (Summative Part 1: network, bastion, private VM, load balancer)
# Public entry point for the web app. Users open http://<lb_public_ip>/ and the
# load balancer forwards port 80 to the app VM's app_port.
#
# Azure retired implicit default outbound access for new VNets (31 March
# 2026), so the private VM would otherwise have no internet access at all
# for apt, Docker or the container registry. azurerm_lb_outbound_rule below
# gives it that path explicitly through this same load balancer.

resource "azurerm_public_ip" "lb" {
  name                = "${local.name_prefix}-lb-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_lb" "app" {
  name                = "${local.name_prefix}-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  tags                = local.common_tags

  frontend_ip_configuration {
    name                 = "public"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "app" {
  name            = "app-vms"
  loadbalancer_id = azurerm_lb.app.id
}

resource "azurerm_network_interface_backend_address_pool_association" "app" {
  network_interface_id    = azurerm_network_interface.app.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.app.id
}

# The load balancer only sends traffic to a VM whose health probe answers
resource "azurerm_lb_probe" "app" {
  name            = "app-health"
  loadbalancer_id = azurerm_lb.app.id
  protocol        = "Http"
  port            = var.app_port
  request_path    = "/api/health"
}

resource "azurerm_lb_rule" "web" {
  name                           = "web"
  loadbalancer_id                = azurerm_lb.app.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = var.app_port
  frontend_ip_configuration_name = "public"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app.id]
  probe_id                       = azurerm_lb_probe.app.id
}

# Explicit outbound path for the private app VM (apt, Docker, ACR pulls).
# Required since Azure no longer grants this implicitly for new VNets.
resource "azurerm_lb_outbound_rule" "app" {
  name                     = "outbound"
  loadbalancer_id          = azurerm_lb.app.id
  protocol                 = "All"
  backend_address_pool_id  = azurerm_lb_backend_address_pool.app.id
  allocated_outbound_ports = 1024

  frontend_ip_configuration {
    name = "public"
  }
}
