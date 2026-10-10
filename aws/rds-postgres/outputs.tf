output "endpoint" {
  description = "PostgreSQL endpoint including port; no credentials."
  value       = aws_db_instance.this.endpoint
}

output "database_name" {
  description = "Initial database name."
  value       = aws_db_instance.this.db_name
}

output "master_secret_arn" {
  description = "ARN of the RDS-managed master credential secret; its value is never retrieved."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "security_group_id" {
  description = "Database security group ID."
  value       = aws_security_group.this.id
}
