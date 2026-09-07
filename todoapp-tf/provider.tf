// providers.tf
terraform {
  required_version = ">= 1.1.0"

  backend "azurerm" {
    resource_group_name  = "agentic-tfstate-rg"
    storage_account_name = "agenticdevopstfstate"
    container_name       = "tfstate"
    key                  = "agentic-devops.tfstate"
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
  subscription_id = "3863b33b-9c78-424a-a7df-289b82e3ea3e"
  resource_provider_registrations = "none"
}

provider "random" {}
