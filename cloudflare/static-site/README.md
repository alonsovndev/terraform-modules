# Cloudflare static site

Deploy prebuilt static assets to a Worker and attach optional custom domains.

## Usage

Example from a root two directories below the repository root. Configure the provider and backend in that consuming root; published consumers should pin the repository source to a reviewed commit or release.

```hcl
module "static_site" {
  source = "../../cloudflare/static-site"
  account_id = var.account_id
  name = "example-static"
  assets_directory = "${path.root}/dist"
  custom_domains = { "www.example.com" = var.zone_id }
}
```

## Inputs

| Name | Type | Default | Meaning |
|---|---|---|---|
| `account_id` | `string` | Required | Cloudflare account ID; supply credentials through CLOUDFLARE_API_TOKEN. |
| `name` | `string` | Required | Resource name prefix; use lowercase letters, digits, and hyphens. |
| `assets_directory` | `string` | Required | Existing built asset directory containing index.html; build before planning. |
| `custom_domains` | `map(string)` | `{}` | Custom hostnames mapped to Cloudflare zone IDs. Do not also manage DNS records for these hostnames. |
| `spa_mode` | `bool` | `false` | Opt into single-page-application fallback for client-side routes. |

## Outputs

| Name | Meaning |
|---|---|
| `worker_name` | Worker name managed by Terraform. |
| `custom_domain_urls` | HTTPS URLs keyed by custom-domain hostname. |

## Operational constraints

Build assets before planning; assets_directory must contain index.html. Terraform owns the Worker, assets, and custom-domain bindings. Do not deploy the same Worker independently with Wrangler. Provider 5.27.0 computes an asset-manifest fingerprint for file changes; mocks do not verify uploads or actual redeployment. Default handling uses ordinary static HTML redirects and 404-page behavior; supply 404.html if required. spa_mode opts into client-side route fallback. Worker compatibility date is 2026-10-01. Supply security headers in the built _headers file. Existing zones and certificate/DNS activation remain caller prerequisites.

## Verification

Run the repository checks in [development](../../docs/development.md). Tests use plan-only provider mocks; they do not establish deployment or runtime correctness. See [deployment prerequisites](../../docs/deployment.md).
