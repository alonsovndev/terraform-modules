provider "aws" {
  region = "us-east-1"
}

variable "github_repository" {
  description = "Exact GitHub owner/repository permitted to request the role."
  type        = string
}

variable "bucket_arn" {
  description = "Existing deployment bucket ARN; role permissions are limited to this bucket."
  type        = string
}

variable "existing_provider_arn" {
  description = "Existing account-wide GitHub OIDC provider ARN, or null to create one."
  type        = string
  default     = null
}

variable "create_provider" {
  description = "Create the account-wide provider, or set false when passing an existing_provider_arn."
  type        = bool
  default     = true
  nullable    = false
}

module "github" {
  source                = "../../aws/github-oidc"
  name                  = "example-github"
  existing_provider_arn = var.existing_provider_arn
  create_provider       = var.create_provider
  roles = {
    static = {
      subjects = ["repo:${var.github_repository}:ref:refs/heads/main"]
      policy_json = jsonencode({
        Version = "2012-10-17"
        Statement = [
          { Effect = "Allow", Action = ["s3:ListBucket"], Resource = var.bucket_arn },
          { Effect = "Allow", Action = ["s3:PutObject"], Resource = "${var.bucket_arn}/*" }
        ]
      })
    }
  }
}

output "deployment_role_arn" {
  description = "Role ARN for the consuming GitHub workflow."
  value       = module.github.role_arns["static"]
}
