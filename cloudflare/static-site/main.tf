resource "cloudflare_workers_script" "this" {
  account_id         = var.account_id
  script_name        = var.name
  main_module        = "worker.js"
  content            = file("${path.module}/worker.js")
  compatibility_date = "2026-10-01"

  bindings = [{ name = "ASSETS", type = "assets" }]

  assets = {
    directory = abspath(var.assets_directory)
    config = {
      html_handling      = "auto-trailing-slash"
      not_found_handling = var.spa_mode ? "single-page-application" : "404-page"
    }
  }
}

resource "cloudflare_workers_custom_domain" "this" {
  for_each = var.custom_domains

  account_id = var.account_id
  hostname   = each.key
  zone_id    = each.value
  service    = cloudflare_workers_script.this.script_name
}
