terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  
  # Disable automatic provider registration to prevent 403 errors
  skip_provider_registration = true
  
  # Use variables for subscription and tenant details
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

