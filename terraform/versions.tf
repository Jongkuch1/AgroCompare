terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  # Leave var.subscription_id unset (null) to use the ARM_SUBSCRIPTION_ID
  # environment variable instead, so no account ID is ever committed.
  subscription_id = var.subscription_id
}
