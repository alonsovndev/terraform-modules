# Cloudflare static hosting example

Compose an owned-domain zone, a Worker with example assets, its `www` custom domain, and a separate placeholder TXT record.

Supply `account_id` and an already-owned `domain`; authenticate through `CLOUDFLARE_API_TOKEN`. Existing zones need approved import or direct zone-ID consumption. Update registrar nameservers manually, then validate DNS activation and certificate issuance. See [deployment prerequisites](../../docs/deployment.md).

Replace the example assets with your prebuilt site. Terraform owns asset deployment. The custom-domain resource owns routing for `www`; the DNS module manages only the separate TXT record.

## Local verification

From the repository root, run `make ci`. The mocked test checks zone/Worker/DNS wiring. It does not upload assets or verify DNS, certificates, or content-change deployment.
