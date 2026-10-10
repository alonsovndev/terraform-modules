mock_provider "cloudflare" {
  source          = "../../tests/cloudflare"
  override_during = plan
}

variables {
  account_id = "00000000000000000000000000000000"
  domains    = ["example.com"]
}

run "owned_domain_zone" {
  command = plan
  assert {
    condition     = cloudflare_zone.this["example.com"].type == "full" && cloudflare_zone.this["example.com"].account.id == var.account_id
    error_message = "Create a full zone in the supplied account."
  }
  assert {
    condition     = output.zone_ids["example.com"] == "11111111111111111111111111111111" && length(output.name_servers["example.com"]) == 2
    error_message = "Return zone IDs and registrar activation nameservers."
  }
}

run "invalid_account_id" {
  command = plan
  variables {
    account_id = "invalid"
  }
  expect_failures = [var.account_id]
}

run "invalid_domain" {
  command = plan
  variables {
    domains = ["invalid"]
  }
  expect_failures = [var.domains]
}
