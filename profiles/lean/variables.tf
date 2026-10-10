variable "project_name" {
  description = "Name prefix for the ECR repository, Lambda function, API, and static site; lowercase letters, digits, and hyphens."
  type        = string
  nullable    = false
}

variable "aws_region" {
  description = "AWS region for ECR, Lambda, and the API."
  type        = string
  default     = "us-east-1"
  nullable    = false
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID; use CLOUDFLARE_API_TOKEN for authentication."
  type        = string
  nullable    = false
}

variable "domain" {
  description = "Owned apex domain that hosts the web app."
  type        = string
  nullable    = false
}

variable "web_hostname" {
  description = "Web app hostname, either the domain itself or a subdomain of it."
  type        = string
  nullable    = false

  validation {
    condition     = var.web_hostname == var.domain || endswith(var.web_hostname, ".${var.domain}")
    error_message = "The web hostname must be the domain or a subdomain of it."
  }
}

variable "existing_zone_id" {
  description = "ID of a zone that already exists in Cloudflare. Leave null to create the zone from the domain."
  type        = string
  default     = null
}

variable "web_assets_directory" {
  description = "Built web app directory containing index.html. Build with VITE_API_BASE_URL set to the api_endpoint output."
  type        = string
  nullable    = false

  validation {
    condition     = fileexists("${var.web_assets_directory}/index.html")
    error_message = "Build the web app first and supply a directory containing index.html."
  }
}

variable "api_image_uri" {
  description = "Digest-pinned image in this profile's ECR repository, built with the Dockerfile lambda target."
  type        = string
  nullable    = false
}

variable "database_secret_arn" {
  description = "ARN of a Secrets Manager secret you create by hand holding {\"username\": \"...\", \"password\": \"...\"} for the database. Terraform never reads its value."
  type        = string
  nullable    = false
}

variable "postgres_host" {
  description = "Supabase connection pooler hostname (IPv4). Confirm in the Supabase dashboard; direct connections may be IPv6-only."
  type        = string
  nullable    = false
}

variable "postgres_port" {
  description = "Pooler port. The transaction pooler is normally 6543 and the session pooler 5432."
  type        = number
  default     = 6543
  nullable    = false
}

variable "postgres_database" {
  description = "Database name."
  type        = string
  default     = "postgres"
  nullable    = false
}

variable "github_repository" {
  description = "Exact owner/repository allowed to push images, for example example-owner/example-api."
  type        = string
  nullable    = false
}

variable "github_environment" {
  description = "GitHub environment whose jobs may push images."
  type        = string
  default     = "production"
  nullable    = false
}

variable "create_github_provider" {
  description = "Create the account-wide GitHub OIDC provider. Set false and supply existing_github_provider_arn when the account has one."
  type        = bool
  default     = true
  nullable    = false
}

variable "existing_github_provider_arn" {
  description = "Existing GitHub OIDC provider ARN, used when create_github_provider is false."
  type        = string
  default     = null
}
