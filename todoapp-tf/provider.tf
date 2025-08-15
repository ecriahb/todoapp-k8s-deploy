// providers.tf
terraform {
  required_version = ">= 1.1.0"

  backend "azurerm" {
    resource_group_name   = "zelectric-rg"
    storage_account_name  = "todoapptftest"   # must be globally unique
    container_name        = "tfstate"
    key                   = "todoapp-demo.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "ec998bb0-bbb9-4c41-8983-b66714ad3652"
  resource_provider_registrations = "none"
}

provider "random" {}
