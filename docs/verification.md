# Verification record

Phase 3 verification is local only. Checks ran against the completed Terraform module repository.

## Status

`make ci` passed using Terraform 1.12.0, AWS provider 6.68.0, and Cloudflare provider 5.27.0:

- Backend-free initialization and Terraform formatting checks passed.
- All 17 configurations passed `terraform validate`.
- All 57 plan-only tests passed across 17 suites with mocked cloud providers.
- Documentation checks passed for all 31 Markdown files.

The configurations include 11 library modules, five example compositions, and an unknown-value regression fixture. The fixture verifies optional IAM policy and existing OIDC provider references whose values are unavailable until apply.

Terraform and code reviews completed with no remaining blocking findings. No cloud infrastructure was provisioned, remote workflows triggered, or changes committed or pushed.

## Unverified deployment behavior

Cloud account permissions, resource provisioning, Lambda runtime/image compatibility, ACM/DNS activation, Cloudflare uploads and content-change redeployment, application/database integration, and actual operating costs require approved real-project validation (Phase 4 follow-up).

## Phase 4: deployment profiles

The `static`, `lean`, and `enterprise` roots under `profiles/` are validated offline:

- Each passes backend-free initialization, `terraform fmt`, `terraform validate`, and its mocked plan tests (static 4, lean 5, enterprise 9). The numbers are counted by `make ci`.
- During development, the static and lean roots also passed their plan tests against real builds of `template-docs` and `template-react-vite`, and the reference API (`template-api-python`) built for the default and `lambda` targets and served `/health` and `/health/ready` locally. Those runs are not part of `make ci`, and the application changes they depend on (Lambda target, SSL and pooler settings, credentials from Secrets Manager) are on unreleased template branches.
- Profile tests inspect the roles, secrets, and subnets a root configures through root outputs, because child-module resources are not visible to assertions. Mocked tests override some resource attributes with fixed values, so unknown values in a first real plan are covered only by the Phase 3 unknown-values fixture.

Still unverified: everything that needs an account or a live service, including IAM permissions, Lambda Web Adapter behavior inside Lambda, Supabase pooler and SSL behavior, ECS and ALB health, RDS connectivity, CloudFront and Cloudflare activation, OIDC role assumption, and costs. No profile has been applied.
