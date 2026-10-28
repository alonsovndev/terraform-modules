# Deployment profiles

Three composition roots that wire the library modules into the platform's deployment profiles. Each is a starting point for a project's `infra/profiles/<name>/`: copy it, point the `source` paths at a pinned release of this repository, add a remote backend, and fill in the variables.

| Profile | Web | API | Database | Target cost |
|---|---|---|---|---|
| [static](static/README.md) | Cloudflare Workers static assets | None | None | About $0 (unverified) |
| [lean](lean/README.md) | Cloudflare Workers static assets | FastAPI container on Lambda behind API Gateway | Supabase PostgreSQL, created by hand | About $0-10/month (unverified) |
| [enterprise](enterprise/README.md) | S3 + CloudFront | FastAPI container on ECS Fargate behind an ALB | RDS PostgreSQL | Varies; NAT, ALB, and RDS cost money (TBD) |

## Status

Validated offline only: `terraform validate`, mocked-provider plan tests, and local builds of the reference applications (`template-docs`, `template-react-vite`, `template-api-python`). Nothing has been applied to a real account, so no profile is claimed deployment-ready. See [verification](../docs/verification.md) and [ADR-004](../docs/adr/adr-004-deployment-profiles.md).

## Shared rules

- **State and credentials belong to the project.** No backend is configured. Use `CLOUDFLARE_API_TOKEN` and GitHub OIDC; never commit tokens, variable files, state, or plans.
- **Images are built outside Terraform** and referenced by digest. Bootstrap order for the API profiles: apply only the ECR repository and the OIDC provider and roles (`terraform apply -target=module.repository -target=module.github`), push an image with the `docker-push` workflow, then apply everything with `api_image_uri` set to that digest. Terraform still requires every root variable and validates them, so pass the placeholder values from `terraform.tfvars.example` for inputs the targeted modules do not use, including a directory that contains an `index.html` for the web assets.
- **Deploys go through Terraform.** The API image digest and the Cloudflare assets are Terraform inputs, so a release is a reviewed plan and apply (`terraform-plan` and `terraform-apply` workflows). Do not also run `deploy-ecs` or `aws lambda update-function-code`; that would drift from state. On ECS a new digest probably replaces the task definition (unverified, from provider behavior), which the apply workflow's destructive-plan guard blocks unless `allow-destroy: true`; review the plan's delete list first.
- **Projects own the Terraform apply role and backend.** No profile creates an apply or plan role, and none configures remote state. Both are project decisions (TBD); the `terraform-*` workflows need a `role-arn` and `backend-config`.
- **CI trusts one GitHub environment.** The OIDC roles accept only `repo:<owner>/<repo>:environment:<name>` (the OIDC module rejects wildcards), so jobs that push images must declare that environment. That subject carries no branch or tag, so the environment must restrict deployment branches or tags and require reviewers; otherwise any branch workflow in the repository can push images or, in the enterprise profile, publish the production web app.
- **Secrets stay out of Terraform values.** The application reads database credentials from Secrets Manager (`POSTGRES_CREDENTIALS_SECRET_ARN` on Lambda, an ECS secret on ECS). `template-api-python` supports both once its Phase 4 branch is released (pending). Credentials are read at startup, so restart the service after a rotation; RDS-managed secrets rotate automatically.
- **Build the web app per environment.** `VITE_API_BASE_URL` is baked in at build time, so the API URL must exist first. Apply the API, build the web app, then apply the web part.
- **Keep one root per environment.** Use separate state and variable values for production and staging.
