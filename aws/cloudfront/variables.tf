variable "name" {
  type        = string
  description = "Resource name prefix; use lowercase letters, digits, and hyphens."
  nullable    = false
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.name))
    error_message = "Use a 3\u201332 character lowercase name beginning with a letter and ending with a letter or digit."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags attached to taggable AWS resources."
  default     = {}
  nullable    = false
}

variable "bucket_regional_domain_name" {
  type        = string
  description = "Private S3 bucket regional REST hostname, not an S3 website endpoint."
  nullable    = false
  validation {
    condition     = can(regex("\\.s3\\.[a-z0-9-]+\\.amazonaws\\.com(\\.cn)?$", var.bucket_regional_domain_name))
    error_message = "Supply an S3 regional REST hostname."
  }
}

variable "aliases" {
  type        = set(string)
  description = "Optional custom hostnames covered by the supplied ACM certificate."
  default     = []
  nullable    = false
}

variable "acm_certificate_arn" {
  type        = string
  description = "Validated ACM certificate in us-east-1; required exactly when custom aliases are supplied."
  default     = null
  nullable    = true
  validation {
    condition     = length(var.aliases) == 0 ? var.acm_certificate_arn == null : can(regex("^arn:aws:acm:us-east-1:[0-9]{12}:certificate/[a-f0-9-]+$", var.acm_certificate_arn))
    error_message = "Custom aliases require an ACM certificate from us-east-1; omit the certificate for the default CloudFront hostname."
  }
}

variable "spa_mode" {
  type        = bool
  description = "Opt into serving index.html with HTTP 200 for S3 403/404 responses."
  default     = false
  nullable    = false
}
