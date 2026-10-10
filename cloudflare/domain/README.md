# Cloudflare domain

Create full DNS zones for already-owned domains and return nameservers for manual registrar activation.

## Usage

Example from a root two directories below the repository root. Configure the provider and backend in that consuming root; published consumers should pin the repository source to a reviewed commit or release.

```hcl
module "domain" {
  source = "../../cloudflare/domain"
  account_id = var.account_id
  domains = ["example.com"]
}
```

## Inputs

| Name | Type | Default | Meaning |
|---|---|---|---|
| `account_id` | `string` | Required | Cloudflare account ID; supply credentials through CLOUDFLARE_API_TOKEN. |
| `domains` | `set(string)` | Required | Already-owned domain names; Terraform creates DNS zones, not registrations. |

## Outputs

| Name | Meaning |
|---|---|
| `zone_ids` | Zone IDs keyed by domain name. |
| `name_servers` | Assigned nameservers keyed by domain; update the registrar manually. |

## Operational constraints

This module does not purchase, transfer, or renew domains. Existing zones require a separately approved import into the chosen root state, or callers can supply existing zone IDs directly to DNS and static-site modules. Zone deletion is blocked with lifecycle.prevent_destroy; removing the protection requires a reviewed module change. Terraform does not update registrar nameservers.

## Verification

Run the repository checks in [development](../../docs/development.md). Tests use plan-only provider mocks; they do not establish deployment or runtime correctness. See [deployment prerequisites](../../docs/deployment.md).
