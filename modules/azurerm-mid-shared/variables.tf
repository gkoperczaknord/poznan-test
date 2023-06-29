variable "name" {
  description = "Name of resource."
  type        = string
}

variable "resource_group_name" {
  description = "Name of resource group to deploy resources in."
  type        = string
}

variable "location" {
  description = "Azure location where resources should be deployed."
  type        = string
}

variable "app_role_assignments" {
  description = "List of app role assignments to granted for managed identity."
  type = list(object({
    resource_app_id = optional(string, "MicrosoftGraph")
    app_role_id     = string
  }))
  default = []
}

variable "federated_kubernetes_identity" {
  description = "Config for setting up federated Kubernetes workload identity."
  type = list(object({
    cluster_issuer       = string,
    namespace            = string,
    service_account_name = string,
  }))
  default = []
}
