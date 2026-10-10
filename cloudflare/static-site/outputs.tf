output "worker_name" {
  description = "Worker name managed by Terraform."
  value       = cloudflare_workers_script.this.script_name
}

output "custom_domain_urls" {
  description = "HTTPS URLs keyed by custom-domain hostname."
  value       = { for hostname, domain in cloudflare_workers_custom_domain.this : hostname => "https://${domain.hostname}" }
}
