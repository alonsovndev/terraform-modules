provider "cloudflare" {}

variable "account_id" {
  description = "Cloudflare account ID; use CLOUDFLARE_API_TOKEN for authentication."
  type        = string
}

variable "domain" {
  description = "Domain you already own; existing Cloudflare zones must be imported separately before use."
  type        = string
}

module "domain" {
  source     = "../../cloudflare/domain"
  account_id = var.account_id
  domains    = [var.domain]
}

module "site" {
  source           = "../../cloudflare/static-site"
  account_id       = var.account_id
  name             = "example-static"
  assets_directory = "${path.module}/assets"
  custom_domains   = { "www.${var.domain}" = module.domain.zone_ids[var.domain] }
}

module "dns" {
  source = "../../cloudflare/dns"
  records = {
    verification = {
      zone_id = module.domain.zone_ids[var.domain]
      name    = "_example.${var.domain}"
      type    = "TXT"
      content = "example-verification-placeholder"
    }
  }
}

output "nameservers" {
  description = "Activate the zone by updating the domain registrar manually."
  value       = module.domain.name_servers
}

output "site_urls" {
  description = "Custom domain URLs; DNS and certificate activation remain live validation steps."
  value       = module.site.custom_domain_urls
}
