output "bucket_name" {
  description = "Bucket name."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "Bucket ARN for caller-owned bucket policy statements."
  value       = aws_s3_bucket.this.arn
}

output "regional_domain_name" {
  description = "Regional S3 REST endpoint for a CloudFront origin."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
