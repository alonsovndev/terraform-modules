output "zone_ids" {
  description = "Zone IDs keyed by domain name."
  value       = { for domain, zone in cloudflare_zone.this : domain => zone.id }
}

output "name_servers" {
  description = "Assigned nameservers keyed by domain; update the registrar manually."
  value       = { for domain, zone in cloudflare_zone.this : domain => zone.name_servers }
}
