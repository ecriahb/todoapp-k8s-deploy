// providers.tf
terraform {
  required_version = ">= 1.1.0"

  backend "azurerm" {
    resource_group_name   = "todoapp-tf"
    storage_account_name  = "todoapptf"   # must be globally unique
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
  subscription_id = "01b89ee8-caef-4e87-ab38-ab8c27a7da58"
  resource_provider_registrations = "none"
}

provider "random" {}
