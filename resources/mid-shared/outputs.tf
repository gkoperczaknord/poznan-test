output "identity_id" {
  description = "The ID of the User Assigned Identity."
  value       = module.mid.identity_id
}

output "client_id" {
  description = "The ID of the app associated with the Identity."
  value       = module.mid.client_id
}

output "principal_id" {
  description = "The ID of the Service Principal object associated with the created Identity."
  value       = module.mid.principal_id
}

output "tenant_id" {
  description = "The ID of the Tenant which the Identity belongs to."
  value       = module.mid.tenant_id
}
