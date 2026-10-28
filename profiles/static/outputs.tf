output "site_urls" {
  description = "Custom domain URLs. Certificate and DNS activation need live confirmation."
  value       = module.site.custom_domain_urls
}

output "nameservers" {
  description = "Set these at the registrar to activate a newly created zone; empty when an existing zone is used."
  value       = var.existing_zone_id == null ? module.domain[0].name_servers[var.domain] : []
}
