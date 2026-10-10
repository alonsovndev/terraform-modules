variable "project_name" {
  description = "Name prefix for every resource; lowercase letters, digits, and hyphens."
  type        = string
  nullable    = false
}

variable "aws_region" {
  description = "AWS region. CloudFront certificates must be in us-east-1, so keep the default unless the site uses the default CloudFront hostname."
  type        = string
  default     = "us-east-1"
  nullable    = false
}

variable "availability_zones" {
  description = "Two availability zones in the region. Subnets are assigned in sorted zone order."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.availability_zones) == 2 && length(distinct(var.availability_zones)) == 2
    error_message = "Supply exactly two distinct availability zones."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR for the VPC, a /16 or larger; it is split into /24 public and private subnets."
  type        = string
  default     = "10.20.0.0/16"
  nullable    = false

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && tonumber(split("/", var.vpc_cidr)[1]) <= 16
    error_message = "Supply an IPv4 CIDR with a prefix length of 16 or less."
  }
}

variable "enable_nat_gateway" {
  description = "Create a paid NAT gateway per zone so private tasks can reach ECR, Secrets Manager, and logs. Without it you must provide VPC endpoints."
  type        = bool
  default     = true
  nullable    = false
}

variable "api_image_uri" {
  description = "Digest-pinned image in this profile's ECR repository, built with the default Dockerfile target."
  type        = string
  nullable    = false
}

variable "api_certificate_arn" {
  description = "Validated ACM certificate in the region for the API hostname served by the load balancer."
  type        = string
  nullable    = false
}

variable "api_allowed_ingress_cidrs" {
  description = "IPv4 CIDRs allowed to reach the load balancer over HTTPS. The default is open to the internet."
  type        = set(string)
  default     = ["0.0.0.0/0"]
  nullable    = false
}

variable "postgres_version" {
  description = "Supported PostgreSQL engine version available in the region."
  type        = string
  nullable    = false
}

variable "multi_az" {
  description = "Enable the paid Multi-AZ database standby."
  type        = bool
  default     = false
  nullable    = false
}

variable "final_snapshot_identifier" {
  description = "Unique name for the final snapshot taken at an approved teardown."
  type        = string
  nullable    = false
}

variable "web_bucket_name" {
  description = "Globally unique name for the private web asset bucket."
  type        = string
  nullable    = false
}

variable "web_aliases" {
  description = "Custom web hostnames covered by web_certificate_arn. Leave empty to use the default CloudFront hostname."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "web_certificate_arn" {
  description = "Validated us-east-1 ACM certificate for web_aliases; null when no aliases are used."
  type        = string
  default     = null
}

variable "github_repository" {
  description = "Exact owner/repository allowed to push images and publish the web app."
  type        = string
  nullable    = false
}

variable "github_environment" {
  description = "GitHub environment whose jobs may push images and publish the web app."
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
