mock_provider "cloudflare" {
  source          = "../../tests/cloudflare"
  override_during = plan
}

variables {
  account_id       = "00000000000000000000000000000000"
  site_name        = "example-docs"
  domain           = "example.com"
  hostname         = "docs.example.com"
  assets_directory = "../../examples/cloudflare-static/assets"
}

run "creates_the_zone_and_binds_the_hostname" {
  command = plan
  assert {
    condition     = output.site_urls["docs.example.com"] == "https://docs.example.com"
    error_message = "Bind the Worker to the requested hostname."
  }
  assert {
    condition     = length(output.nameservers) == 2
    error_message = "Return activation nameservers for a newly created zone."
  }
}

run "reuses_an_existing_zone_without_creating_one" {
  command = plan
  variables {
    existing_zone_id = "11111111111111111111111111111111"
  }
  assert {
    condition     = length(module.domain) == 0 && length(output.nameservers) == 0
    error_message = "Do not create a zone when an existing zone ID is supplied."
  }
  assert {
    condition     = output.site_urls["docs.example.com"] == "https://docs.example.com"
    error_message = "Bind the hostname in the existing zone."
  }
}

run "rejects_a_hostname_outside_the_domain" {
  command = plan
  variables {
    hostname = "docs.other.org"
  }
  expect_failures = [var.hostname]
}

run "requires_built_assets" {
  command = plan
  variables {
    assets_directory = "../../docs"
  }
  expect_failures = [var.assets_directory]
}
