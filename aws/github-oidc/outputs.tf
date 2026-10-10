output "provider_arn" {
  description = "GitHub OIDC provider ARN, created or supplied."
  value       = local.provider_arn
}

output "role_arns" {
  description = "Role ARNs keyed by the caller's role keys."
  value       = { for role_name, role in aws_iam_role.this : role_name => role.arn }
}
