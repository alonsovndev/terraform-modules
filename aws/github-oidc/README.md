# GitHub OIDC

Create or reuse the account-wide GitHub OIDC provider and create roles with exact subject allowlists and caller-owned permissions.

## Usage

Example from a root two directories below the repository root. Configure the provider and backend in that consuming root; published consumers should pin the repository source to a reviewed commit or release.

```hcl
module "github_oidc" {
  source = "../../aws/github-oidc"
  name = "example-github"
  create_provider = false
  existing_provider_arn = var.existing_provider_arn
  roles = {
    static = {
      subjects = ["repo:example-owner/example-repository:ref:refs/heads/main"]
      policy_json = jsonencode({
        Version = "2012-10-17"
        Statement = [{ Effect = "Allow", Action = ["s3:ListBucket"], Resource = var.bucket_arn }]
      })
    }
  }
}
```

## Inputs

| Name | Type | Default | Meaning |
|---|---|---|---|
| `name` | `string` | Required | Resource name prefix; use lowercase letters, digits, and hyphens. |
| `tags` | `map(string)` | `{}` | Tags attached to taggable AWS resources. |
| `existing_provider_arn` | `string` | `null` | GitHub OIDC provider ARN to reuse when create_provider is false; may be unknown during planning. |
| `create_provider` | `bool` | `true` | Create the account-wide provider, or set false to reuse existing_provider_arn. This selection must be known at plan time. |
| `roles` | `map(object({ subjects = set(string), policy_json = string, max_session_duration = optional(number, 3600) }))` | Required | Roles keyed by name, with exact GitHub branch/tag or environment subjects and caller-owned permission policies. |

## Outputs

| Name | Meaning |
|---|---|
| `provider_arn` | GitHub OIDC provider ARN, created or supplied. |
| `role_arns` | Role ARNs keyed by the caller's role keys. |

## Operational constraints

Only exact repository branch/tag and environment subjects are accepted. The STS audience is mandatory; wildcard and pull-request subjects are rejected. Environment subjects do not identify a branch: configure allowed deployment branches and required reviewers in GitHub environments separately. Reuse an existing account-wide provider via create_provider=false and existing_provider_arn rather than creating it in multiple states. Permission policies are caller-owned and must be reviewed for least privilege. Terraform does not configure GitHub repositories or deploy anything.

## Verification

Run the repository checks in [development](../../docs/development.md). Tests use plan-only provider mocks; they do not establish deployment or runtime correctness. See [deployment prerequisites](../../docs/deployment.md).
