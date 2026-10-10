variable "account_id" {
  type        = string
  description = "Cloudflare account ID; supply credentials through CLOUDFLARE_API_TOKEN."
  nullable    = false
  validation {
    condition     = can(regex("^[a-f0-9]{32}$", var.account_id))
    error_message = "Supply a 32-character hexadecimal Cloudflare account ID."
  }
}

variable "domains" {
  type        = set(string)
  description = "Already-owned domain names; Terraform creates DNS zones, not registrations."
  nullable    = false
  validation {
    condition     = length(var.domains) > 0 && alltrue([for domain in var.domains : length(domain) <= 253 && can(regex("^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z]{2,63}$", domain))])
    error_message = "Supply nonempty lowercase fully qualified domain names without trailing dots."
  }
}
