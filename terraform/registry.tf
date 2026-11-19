# Owner: AgertuDA (Summative Part 2: container registry, managed database, security gates)
# Private container registry (ACR). The CD pipeline pushes the backend and
# frontend images here, and the app VM pulls them from here.
#
# This file relies on names from main.tf (Jongkuch1): local.name_prefix,
# local.common_tags, azurerm_resource_group.main.


# Registry names must be globally unique and use only letters and numbers
resource "random_string" "registry_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_container_registry" "main" {
  # Accepted risks (the Basic tier is the cheapest and enough for this course):
  #checkov:skip=CKV_AZURE_165:Geo-replication needs the Premium tier; not needed for a single-region demo
  #checkov:skip=CKV_AZURE_167:Untagged-image retention needs the Premium tier
  #checkov:skip=CKV_AZURE_233:Zone redundancy needs the Premium tier
  #checkov:skip=CKV_AZURE_164:Image signing (content trust) needs the Premium tier
  #checkov:skip=CKV_AZURE_166:Image quarantine needs the Premium tier
  #checkov:skip=CKV_AZURE_139:Public network access is needed so the GitHub runner can push; access needs a login
  #checkov:skip=CKV_AZURE_163:Defender image scanning is a paid add-on; images are scanned with Trivy in the CI/CD pipeline instead
  #checkov:skip=CKV_AZURE_237:Dedicated data endpoints need the Premium tier

  name                = "${replace(var.project_name, "-", "")}${var.environment}${random_string.registry_suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"

  # No shared admin user: the pipeline and the VM log in with a service principal
  admin_enabled = false

  tags = local.common_tags
}

output "registry_name" {
  description = "Name of the container registry (put it in the GitHub variable ACR_NAME)."
  value       = azurerm_container_registry.main.name
}

output "registry_login_server" {
  description = "Registry address used in image names, for example myregistry.azurecr.io."
  value       = azurerm_container_registry.main.login_server
}
