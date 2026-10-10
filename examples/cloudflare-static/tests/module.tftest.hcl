mock_provider "cloudflare" {
  source          = "../../tests/cloudflare"
  override_during = plan
}

variables {
  account_id = "00000000000000000000000000000000"
  domain     = "example.com"
}

run "zone_worker_dns_wiring" {
  command = plan
  assert {
    condition     = output.site_urls["www.example.com"] == "https://www.example.com"
    error_message = "Connect the Worker custom domain to the created zone."
  }
  assert {
    condition     = length(output.nameservers["example.com"]) == 2 && length(module.dns.record_ids) == 1
    error_message = "Return activation nameservers and manage only the separate verification DNS record."
  }
}
