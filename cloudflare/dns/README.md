# Cloudflare DNS

Manage A, AAAA, CNAME, TXT, MX, and NS records with stable caller-chosen keys.

## Usage

Example from a root two directories below the repository root. Configure the provider and backend in that consuming root; published consumers should pin the repository source to a reviewed commit or release.

```hcl
module "dns" {
  source = "../../cloudflare/dns"
  records = {
    web = {
      zone_id = var.zone_id
      name = "app.example.com"
      type = "A"
      content = "192.0.2.1"
      proxied = true
    }
  }
}
```

## Inputs

| Name | Type | Default | Meaning |
|---|---|---|---|
| `records` | `map(object({ zone_id = string, name = string, type = string, content = string, ttl = optional(number, 1), proxied = optional(bool, false), priority = optional(number) }))` | Required | A, AAAA, CNAME, TXT, MX, or NS records keyed by stable identifiers; TTL 1 means automatic. |

## Outputs

| Name | Meaning |
|---|---|
| `record_ids` | DNS record IDs keyed by the caller's stable record keys. |
| `record_names` | DNS record names keyed by the caller's stable record keys. |

## Operational constraints

Only A, AAAA, and CNAME records may be proxied, and proxied records require automatic TTL (1). DNS-only records allow automatic TTL or 60–86400 seconds. MX records require a 0–65535 priority; other supported types do not accept it. SRV, CAA, DNSSEC, and advanced record data are outside this baseline. Do not create records for hostnames owned by Workers custom-domain resources. Record activation and external DNS behavior remain live checks.

## Verification

Run the repository checks in [development](../../docs/development.md). Tests use plan-only provider mocks; they do not establish deployment or runtime correctness. See [deployment prerequisites](../../docs/deployment.md).
