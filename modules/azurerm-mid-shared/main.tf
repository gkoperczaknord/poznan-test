terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.6.0, < 4.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.0.0, < 3.0.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "> 1.0.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.0.0"
    }
  }
}

locals {
  guid_regex = "(^([0-9A-Fa-f]{8}[-][0-9A-Fa-f]{4}[-][0-9A-Fa-f]{4}[-][0-9A-Fa-f]{4}[-][0-9A-Fa-f]{12})$)"

  well_known_app_ids = [for app in var.app_role_assignments : app.resource_app_id if length(regexall(local.guid_regex, app.resource_app_id)) == 0]

  app_role_assignments = { for app in var.app_role_assignments : "${app.resource_app_id}_${app.app_role_id}" => {
    resource_app_id = length(regexall(local.guid_regex, app.resource_app_id)) == 0 ? azuread_service_principal.well_known[app.resource_app_id].object_id : app.resource_app_id
    app_role_id     = length(regexall(local.guid_regex, app.app_role_id)) == 0 ? azuread_service_principal.well_known[app.resource_app_id].app_role_ids[app.app_role_id] : app.app_role_id
  } }
}

data "azuread_application_published_app_ids" "well_known" {}

resource "azuread_service_principal" "well_known" {
  for_each = toset(local.well_known_app_ids)

  application_id = data.azuread_application_published_app_ids.well_known.result[each.key]
  use_existing   = true
}

#
# User Managed Identity
#

resource "azurecaf_name" "umid" {
  name          = var.name
  resource_type = "azurerm_user_assigned_identity"
}

resource "azurerm_user_assigned_identity" "this" {
  name                = azurecaf_name.umid.result
  resource_group_name = var.resource_group_name
  location            = var.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

#
# App Role Assignments
#

resource "azuread_app_role_assignment" "this" {
  for_each = local.app_role_assignments

  principal_object_id = azurerm_user_assigned_identity.this.principal_id
  app_role_id         = each.value.app_role_id
  resource_object_id  = each.value.resource_app_id
}

#
# Federated Identity
#

resource "azapi_resource" "federated_k8s" {
  for_each = { for id in var.federated_kubernetes_identity : "${id.namespace}_${id.service_account_name}" => id }

  schema_validation_enabled = false
  name                      = "k8s_${each.key}"
  parent_id                 = azurerm_user_assigned_identity.this.id
  type                      = "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2022-01-31-preview"

  location = var.location
  body = jsonencode({
    properties = {
      issuer    = each.value.cluster_issuer
      subject   = format("system:serviceaccount:%s:%s", each.value.namespace, each.value.service_account_name)
      audiences = ["api://AzureADTokenExchange"]
    }
  })

  lifecycle {
    ignore_changes = [location]
  }
}

