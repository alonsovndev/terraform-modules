output "repository_url" {
  description = "Private ECR repository URL."
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "Private ECR repository ARN."
  value       = aws_ecr_repository.this.arn
}

output "repository_name" {
  description = "Private ECR repository name."
  value       = aws_ecr_repository.this.name
}
