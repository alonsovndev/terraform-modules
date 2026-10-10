output "record_ids" {
  description = "DNS record IDs keyed by the caller's stable record keys."
  value       = { for record_key, record in cloudflare_dns_record.this : record_key => record.id }
}

output "record_names" {
  description = "DNS record names keyed by the caller's stable record keys."
  value       = { for record_key, record in cloudflare_dns_record.this : record_key => record.name }
}
