variable "cluster_issuer" {
  description = "Cluster issuer id"
  type        = string
}

variable "name" {
  description = "Managed identity name"
  type        = string
}

variable "location" {
  description = "Location of resources."
  type        = string
  default     = "polandcentral"
}

variable "service_account_name" {
  description = "Service account used by Managed identity"
  type        = string
}

variable "namespace" {
  description = "Namespace used by service account with Managed identity"
  type        = string
}