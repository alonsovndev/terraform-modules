output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs keyed by availability zone."
  value       = { for availability_zone, subnet in aws_subnet.public : availability_zone => subnet.id }
}

output "private_subnet_ids" {
  description = "Private subnet IDs keyed by availability zone."
  value       = { for availability_zone, subnet in aws_subnet.private : availability_zone => subnet.id }
}
