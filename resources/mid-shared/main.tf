terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0, < 4.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "> 2.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "rgrp-mid"
  location = var.location
}

module "mid" {
  source = "../../modules/azurerm-mid"

  name                = var.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  federated_kubernetes_identity = [
    {
      cluster_issuer       = var.cluster_issuer
      namespace            = var.namespace
      service_account_name = var.service_account_name
    }
  ]
}
