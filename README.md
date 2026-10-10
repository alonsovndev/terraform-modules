# Terraform modules

Reusable AWS and Cloudflare infrastructure modules for the engineering platform. Phase 3 supplies module contracts and local verification; Phase 4 adds the static, lean, and enterprise deployment profiles, validated offline only.

## Modules

| AWS | Cloudflare |
|---|---|
| [VPC](aws/vpc/README.md) | [Domain zones](cloudflare/domain/README.md) |
| [ECR](aws/ecr/README.md) | [DNS records](cloudflare/dns/README.md) |
| [ECS service](aws/ecs-service/README.md) | [Workers static site](cloudflare/static-site/README.md) |
| [RDS PostgreSQL](aws/rds-postgres/README.md) | |
| [S3 static origin](aws/s3-static-site/README.md) | |
| [CloudFront](aws/cloudfront/README.md) | |
| [Lambda FastAPI](aws/lambda-fastapi/README.md) | |
| [GitHub OIDC](aws/github-oidc/README.md) | |

## Deployment profiles

| Profile | Shape |
|---|---|
| [static](profiles/static/README.md) | Cloudflare Workers static assets |
| [lean](profiles/lean/README.md) | Cloudflare static web, FastAPI on Lambda, Supabase PostgreSQL |
| [enterprise](profiles/enterprise/README.md) | S3 + CloudFront, FastAPI on ECS Fargate, RDS PostgreSQL |

See [profiles](profiles/README.md) for shared rules and status.

## Local checks

Use Terraform 1.12.0, Make, POSIX sh, and Python 3 for the documentation checker. Provider downloads require access to the Terraform registry. The example roots pin AWS 6.68.0 and Cloudflare 5.27.0; their lock files are checked in.

```bash
make ci
```

Checks initialize without backends, validate every module, example, and profile, and run plan-only provider mocks. They do not use cloud credentials or create cloud resources. See [development](docs/development.md) and [testing](docs/testing.md).

## Consumption

Configure providers, credentials, and remote state in the consuming root. Module examples use relative checkout paths. Git consumers should pin a reviewed commit or release; no release is published by this change.

```hcl
module "repository" {
  source = "git::https://github.com/alonsovndev/terraform-modules.git//aws/ecr?ref=<reviewed-commit-or-tag>"
  name   = "example-api"
}
```

Use the [composition examples](examples/README.md) to understand wiring. They are infrastructure examples with placeholders and prerequisites; the [profiles](profiles/README.md) are the complete compositions. Review [deployment prerequisites](docs/deployment.md) before any real plan or apply.

## Decisions and status

See the [documentation index](docs/README.md), [ADRs](docs/adr/README.md), and [verification record](docs/verification.md). Secrets, SQS, and monitoring modules and real-account deployment validation remain follow-up work.
