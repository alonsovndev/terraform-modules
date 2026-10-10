output "cluster_arn" {
  description = "ECS cluster ARN."
  value       = aws_ecs_cluster.this.arn
}

output "service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.this.name
}

output "task_security_group_id" {
  description = "Task security group ID for explicit database access and additional egress rules."
  value       = aws_security_group.task.id
}

output "task_role_arn" {
  description = "Application task role ARN."
  value       = aws_iam_role.task.arn
}

output "execution_role_name" {
  description = "Execution role name for caller-owned customer-managed KMS decryption policies, when required."
  value       = aws_iam_role.execution.name
}

output "load_balancer_dns_name" {
  description = "ALB DNS name; use a DNS alias matching the supplied certificate for HTTPS."
  value       = aws_lb.this.dns_name
}

output "load_balancer_zone_id" {
  description = "ALB hosted zone ID for DNS aliases."
  value       = aws_lb.this.zone_id
}
