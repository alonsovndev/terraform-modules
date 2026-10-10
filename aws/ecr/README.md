# ECR

Create a private, encrypted ECR repository with immutable tags and push scanning.

## Usage

Example from a root two directories below the repository root. Configure the provider and backend in that consuming root; published consumers should pin the repository source to a reviewed commit or release.

```hcl
module "ecr" {
  source = "../../aws/ecr"
  name = "example-api"
}
```

## Inputs

| Name | Type | Default | Meaning |
|---|---|---|---|
| `name` | `string` | Required | Private ECR repository name, optionally including namespace segments. |
| `tags` | `map(string)` | `{}` | Tags attached to taggable AWS resources. |
| `untagged_retention_days` | `number` | `30` | Days before expiring untagged images; retain deployment images under immutable tags. |

## Outputs

| Name | Meaning |
|---|---|
| `repository_url` | Private ECR repository URL. |
| `repository_arn` | Private ECR repository ARN. |
| `repository_name` | Private ECR repository name. |

## Operational constraints

Only untagged images expire. Keep every deployed image under an immutable tag, even when the application references its digest. force_delete is disabled. Build and push images outside Terraform. Creating a repository does not create its first image.

## Verification

Run the repository checks in [development](../../docs/development.md). Tests use plan-only provider mocks; they do not establish deployment or runtime correctness. See [deployment prerequisites](../../docs/deployment.md).
