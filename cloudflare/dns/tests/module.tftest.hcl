mock_provider "cloudflare" {
  source          = "../../tests/cloudflare"
  override_during = plan
}

variables {
  records = { web = { zone_id = "11111111111111111111111111111111", name = "app.example.com", type = "A", content = "192.0.2.1", proxied = true }, mail = { zone_id = "11111111111111111111111111111111", name = "example.com", type = "MX", content = "mail.example.com", priority = 10 } }
}

run "proxy_and_mail_records" {
  command = plan
  assert {
    condition     = cloudflare_dns_record.this["web"].proxied && cloudflare_dns_record.this["web"].ttl == 1 && !cloudflare_dns_record.this["mail"].proxied && cloudflare_dns_record.this["mail"].priority == 10 && length(output.record_ids) == 2
    error_message = "Preserve automatic TTL for proxied records and MX priority for DNS-only mail."
  }
}

run "invalid_proxy_type" {
  command = plan
  variables {
    records = { web = { zone_id = "11111111111111111111111111111111", name = "app.example.com", type = "TXT", content = "192.0.2.1", proxied = true }, mail = { zone_id = "11111111111111111111111111111111", name = "example.com", type = "MX", content = "mail.example.com", priority = 10 } }
  }
  expect_failures = [var.records]
}

run "invalid_proxied_ttl" {
  command = plan
  variables {
    records = { web = { zone_id = "11111111111111111111111111111111", name = "app.example.com", type = "A", content = "192.0.2.1", proxied = true, ttl = 300 }, mail = { zone_id = "11111111111111111111111111111111", name = "example.com", type = "MX", content = "mail.example.com", priority = 10 } }
  }
  expect_failures = [var.records]
}

run "missing_mx_priority" {
  command = plan
  variables {
    records = { web = { zone_id = "11111111111111111111111111111111", name = "app.example.com", type = "A", content = "192.0.2.1", proxied = true }, mail = { zone_id = "11111111111111111111111111111111", name = "example.com", type = "MX", content = "mail.example.com" } }
  }
  expect_failures = [var.records]
}

run "invalid_ipv4" {
  command = plan
  variables {
    records = { web = { zone_id = "11111111111111111111111111111111", name = "app.example.com", type = "A", content = "not-an-ip", proxied = true }, mail = { zone_id = "11111111111111111111111111111111", name = "example.com", type = "MX", content = "mail.example.com", priority = 10 } }
  }
  expect_failures = [var.records]
}
