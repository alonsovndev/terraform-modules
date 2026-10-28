provider "cloudflare" {}

module "domain" {
  count = var.existing_zone_id == null ? 1 : 0

  source     = "../../cloudflare/domain"
  account_id = var.account_id
  domains    = [var.domain]
}

locals {
  zone_id = coalesce(var.existing_zone_id, try(module.domain[0].zone_ids[var.domain], null))
}

module "site" {
  source           = "../../cloudflare/static-site"
  account_id       = var.account_id
  name             = var.site_name
  assets_directory = var.assets_directory
  spa_mode         = var.spa_mode
  custom_domains   = { (var.hostname) = local.zone_id }
}
