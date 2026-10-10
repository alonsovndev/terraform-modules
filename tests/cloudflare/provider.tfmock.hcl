mock_resource "cloudflare_zone" {
  override_during = plan
  defaults = {
    id           = "11111111111111111111111111111111"
    name_servers = ["ns1.example.net", "ns2.example.net"]
  }
}

mock_resource "cloudflare_dns_record" {
  override_during = plan
  defaults        = { id = "22222222222222222222222222222222" }
}
