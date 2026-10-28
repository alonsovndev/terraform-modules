variable "account_id" {
  description = "Cloudflare account ID; use CLOUDFLARE_API_TOKEN for authentication."
  type        = string
  nullable    = false
}

variable "site_name" {
  description = "Worker name; use lowercase letters, digits, and hyphens."
  type        = string
  nullable    = false
}

variable "domain" {
  description = "Owned apex domain that hosts the site."
  type        = string
  nullable    = false
}

variable "hostname" {
  description = "Site hostname, either the domain itself or a subdomain of it."
  type        = string
  nullable    = false

  validation {
    condition     = var.hostname == var.domain || endswith(var.hostname, ".${var.domain}")
    error_message = "The hostname must be the domain or a subdomain of it."
  }
}

variable "existing_zone_id" {
  description = "ID of a zone that already exists in Cloudflare. Leave null to create the zone from the domain."
  type        = string
  default     = null
}

variable "assets_directory" {
  description = "Built site directory containing index.html. Build before planning."
  type        = string
  nullable    = false

  validation {
    condition     = fileexists("${var.assets_directory}/index.html")
    error_message = "Build the site first and supply a directory containing index.html."
  }
}

variable "spa_mode" {
  description = "Serve index.html for unknown paths (single-page apps). Leave false for documentation sites."
  type        = bool
  default     = false
  nullable    = false
}
