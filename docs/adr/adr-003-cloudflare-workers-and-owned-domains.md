# ADR-003: Workers assets and owned-domain zones

Status: Accepted

## Context

The platform needs Cloudflare DNS, domain, and static-site modules. The user selected Workers static assets and management of already-owned domains.

## Decision

Use provider 5.27.0 Workers script assets-directory upload and custom-domain resources. Terraform owns the Worker, uploaded assets, and domain bindings. Build assets before planning, use ordinary static routing by default, and enable SPA fallback explicitly. Domain modules create DNS zones only; purchases, renewals, transfers, and registrar nameserver changes stay manual.

## Alternatives considered

- Cloudflare Pages: a different hosting target from the selected Workers contract.
- Independent Wrangler deployment: creates overlapping ownership of Worker code/assets and Terraform configuration.

## Consequences

The provider's native asset fingerprint handles content changes; no extra replacement/hash layer is added. Mock tests verify configuration mapping, while uploads, content-change redeployment, DNS activation, and certificates require live validation. Existing zones need approved imports or direct zone-ID consumption.
