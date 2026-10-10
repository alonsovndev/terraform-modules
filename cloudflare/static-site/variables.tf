variable "account_id" {
  type        = string
  description = "Cloudflare account ID; supply credentials through CLOUDFLARE_API_TOKEN."
  nullable    = false
  validation {
    condition     = can(regex("^[a-f0-9]{32}$", var.account_id))
    error_message = "Supply a 32-character hexadecimal Cloudflare account ID."
  }
}

variable "name" {
  type        = string
  description = "Resource name prefix; use lowercase letters, digits, and hyphens."
  nullable    = false
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.name))
    error_message = "Use a 3\u201332 character lowercase name beginning with a letter and ending with a letter or digit."
  }
}

variable "assets_directory" {
  type        = string
  description = "Existing built asset directory containing index.html; build before planning."
  nullable    = false
  validation {
    condition     = fileexists("${var.assets_directory}/index.html")
    error_message = "Build the static assets first and supply a directory containing index.html."
  }
}

variable "custom_domains" {
  type        = map(string)
  description = "Custom hostnames mapped to Cloudflare zone IDs. Do not also manage DNS records for these hostnames."
  default     = {}
  nullable    = false
  validation {
    condition     = alltrue([for hostname, zone_id in var.custom_domains : can(regex("^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z]{2,63}$", hostname)) && can(regex("^[a-f0-9]{32}$", zone_id))])
    error_message = "Supply lowercase hostnames and 32-character hexadecimal zone IDs."
  }
}

variable "spa_mode" {
  type        = bool
  description = "Opt into single-page-application fallback for client-side routes."
  default     = false
  nullable    = false
}
