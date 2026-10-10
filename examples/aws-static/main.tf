provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region for the private S3 origin."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique bucket name; replace the example value before deploying."
  type        = string
}

module "bucket" {
  source = "../../aws/s3-static-site"
  name   = var.bucket_name
  tags   = { Example = "aws-static" }
}

module "cdn" {
  source                      = "../../aws/cloudfront"
  name                        = "example-static"
  bucket_regional_domain_name = module.bucket.regional_domain_name
  tags                        = { Example = "aws-static" }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = module.bucket.bucket_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [module.bucket.bucket_arn, "${module.bucket.bucket_arn}/*"]
        Condition = { Bool = { "aws:SecureTransport" = "false" } }
      },
      {
        Sid       = "AllowCloudFrontRead"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${module.bucket.bucket_arn}/*"
        Condition = { StringEquals = { "AWS:SourceArn" = module.cdn.distribution_arn } }
      }
    ]
  })
}

output "site_url" {
  description = "CloudFront URL; upload built assets separately before checking the site."
  value       = "https://${module.cdn.domain_name}"
}
