output "api_endpoint" {
  description = "Public API URL; use it as VITE_API_BASE_URL when building the web app."
  value       = module.api.api_endpoint
}

output "api_environment" {
  description = "Nonsecret Lambda environment variables."
  value       = local.api_environment
}

output "site_urls" {
  description = "Web app URLs. Certificate and DNS activation need live confirmation."
  value       = module.web.custom_domain_urls
}

output "nameservers" {
  description = "Set these at the registrar to activate a newly created zone; empty when an existing zone is used."
  value       = var.existing_zone_id == null ? module.domain[0].name_servers[var.domain] : []
}

output "ecr_repository_url" {
  description = "Repository to push the Lambda image to."
  value       = module.repository.repository_url
}

output "ecr_push_role_arn" {
  description = "Role for the docker-push workflow."
  value       = module.github.role_arns["ecr-push"]
}

output "github_role_subjects" {
  description = "OIDC subjects each CI role trusts."
  value       = { for name, role in local.github_roles : name => role.subjects }
}

output "github_role_policies" {
  description = "Permission policy of each CI role."
  value       = { for name, role in local.github_roles : name => jsondecode(role.policy_json) }
}
