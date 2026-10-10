resource "cloudflare_zone" "this" {
  for_each = var.domains

  account = { id = var.account_id }
  name    = each.value
  type    = "full"

  lifecycle {
    prevent_destroy = true
  }
}
