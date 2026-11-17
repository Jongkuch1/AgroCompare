# Owner: Jongkuch1 (Summative Part 1: network, bastion, private VM, load balancer)
# Shared building blocks. Other people's files (registry.tf, database.tf)
# rely on these names, so do not rename them:
#   local.name_prefix, local.common_tags,
#   azurerm_resource_group.main, azurerm_virtual_network.main
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

resource "azurerm_resource_group" "main" {
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}
