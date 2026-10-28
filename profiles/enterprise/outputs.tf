output "web_url" {
  description = "Default CloudFront URL; publish built assets to the bucket separately."
  value       = "https://${module.cdn.domain_name}"
}

output "web_bucket_name" {
  description = "Bucket that receives the built web app."
  value       = module.bucket.bucket_name
}

output "web_distribution_id" {
  description = "Distribution to invalidate after publishing."
  value       = module.cdn.distribution_id
}

output "api_load_balancer_hostname" {
  description = "Point a hostname matching api_certificate_arn at this load balancer."
  value       = module.api.load_balancer_dns_name
}

output "api_environment" {
  description = "Nonsecret container environment variables."
  value       = local.api_environment
}

output "ecr_repository_url" {
  description = "Repository to push the API image to."
  value       = module.repository.repository_url
}

output "github_role_arns" {
  description = "Roles for the docker-push and web publish workflows, keyed by purpose."
  value       = module.github.role_arns
}

output "api_secret_arns" {
  description = "Secrets Manager ARNs injected into the container, keyed by environment variable."
  value       = local.api_secret_arns
}

output "subnet_cidrs" {
  description = "Subnet CIDRs by availability zone."
  value       = local.subnets
}

output "github_role_subjects" {
  description = "OIDC subjects each CI role trusts."
  value       = { for name, role in local.github_roles : name => role.subjects }
}

output "github_role_policies" {
  description = "Permission policy of each CI role."
  value       = { for name, role in local.github_roles : name => jsondecode(role.policy_json) }
}
