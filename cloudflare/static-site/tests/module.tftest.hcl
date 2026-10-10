mock_provider "cloudflare" {
  source          = "../../tests/cloudflare"
  override_during = plan
}

variables {
  account_id       = "00000000000000000000000000000000"
  name             = "example-static"
  assets_directory = "../../examples/cloudflare-static/assets"
  custom_domains   = { "www.example.com" = "11111111111111111111111111111111" }
}

run "assets_and_custom_domain" {
  command = plan
  assert {
    condition     = cloudflare_workers_script.this.assets.directory == abspath(var.assets_directory) && cloudflare_workers_script.this.assets.config.not_found_handling == "404-page"
    error_message = "Map the built assets to the Worker without implicit SPA fallback."
  }
  assert {
    condition     = cloudflare_workers_custom_domain.this["www.example.com"].service == cloudflare_workers_script.this.script_name && output.custom_domain_urls["www.example.com"] == "https://www.example.com"
    error_message = "Route the supplied custom hostname to this Worker."
  }
  assert {
    condition     = one(cloudflare_workers_script.this.bindings).name == "ASSETS"
    error_message = "Bind the static assets for the worker handler."
  }
}

run "explicit_spa_mode" {
  command = plan
  variables {
    spa_mode = true
  }
  assert {
    condition     = cloudflare_workers_script.this.assets.config.not_found_handling == "single-page-application"
    error_message = "SPA fallback must be explicitly enabled."
  }
}

run "build_required" {
  command = plan
  variables {
    assets_directory = "../../tests/nonexistent-assets"
  }
  expect_failures = [var.assets_directory]
}
