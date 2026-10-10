# VPC

Create a DNS-enabled IPv4 VPC with paired public/private subnets in at least two availability zones.

## Usage

Example from a root two directories below the repository root. Configure the provider and backend in that consuming root; published consumers should pin the repository source to a reviewed commit or release.

```hcl
module "vpc" {
  source = "../../aws/vpc"
  name = "example-network"
  cidr_block = "10.20.0.0/16"
  subnets = {
    us-east-1a = { public_cidr = "10.20.0.0/24", private_cidr = "10.20.10.0/24" }
    us-east-1b = { public_cidr = "10.20.1.0/24", private_cidr = "10.20.11.0/24" }
  }
}
```

## Inputs

| Name | Type | Default | Meaning |
|---|---|---|---|
| `name` | `string` | Required | Resource name prefix; use lowercase letters, digits, and hyphens. |
| `tags` | `map(string)` | `{}` | Tags attached to taggable AWS resources. |
| `cidr_block` | `string` | Required | IPv4 CIDR for the VPC. |
| `subnets` | `map(object({ public_cidr = string, private_cidr = string }))` | Required | Public/private IPv4 CIDRs keyed by availability zone; all must lie inside the VPC and not overlap. |
| `enable_nat_gateway` | `bool` | `false` | Create a paid NAT gateway per availability zone. Without NAT, consumers must arrange private-task outbound access. |

## Outputs

| Name | Meaning |
|---|---|
| `vpc_id` | VPC ID. |
| `public_subnet_ids` | Public subnet IDs keyed by availability zone. |
| `private_subnet_ids` | Private subnet IDs keyed by availability zone. |

## Operational constraints

NAT defaults off because it has a recurring cost. Private workloads need NAT, VPC service endpoints, or another outbound path. Enabling NAT creates one gateway per availability zone. Public subnets do not assign public addresses automatically. Supply nonoverlapping subnet CIDRs inside the VPC; AWS validates containment and overlap during deployment.

## Verification

Run the repository checks in [development](../../docs/development.md). Tests use plan-only provider mocks; they do not establish deployment or runtime correctness. See [deployment prerequisites](../../docs/deployment.md).
