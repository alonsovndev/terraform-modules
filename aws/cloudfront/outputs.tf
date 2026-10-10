output "distribution_id" {
  description = "Distribution ID for deployment invalidations."
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "Distribution ARN for the caller-owned S3 bucket policy."
  value       = aws_cloudfront_distribution.this.arn
}

output "domain_name" {
  description = "CloudFront distribution hostname."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "hosted_zone_id" {
  description = "CloudFront hosted zone ID for DNS aliases."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}
