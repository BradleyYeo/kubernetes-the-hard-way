terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.5.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "4.0.6"
    }
  }
  required_version = ">= 1.9.7"
}

provider "azurerm" {
  features {}
  subscription_id = "9a473ff3-1067-45f6-9ce0-8fb0d19d2dd7"
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "debian-vm-rg"
  location = "Southeast Asia"
}