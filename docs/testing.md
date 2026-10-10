# Testing

Native Terraform tests use mocked AWS and Cloudflare providers with deterministic fixtures. Every run uses `command = plan`; none creates real infrastructure.

## Coverage of behavior

- Network topology, opt-in per-zone NAT, and public-IP defaults.
- Immutable ECR tags and retention limited to untagged images.
- Private encrypted PostgreSQL, backups, managed-password references, and security-group access.
- S3 public-access blocking, encryption, ownership, versioning, and composition-owned policy.
- CloudFront origin signing, HTTPS redirects, certificate requirements, and explicit SPA fallback.
- Private ECS tasks, listener routing, execution-role permissions, secret references, and task sizing.
- Lambda image configuration, regional compatibility checks, HTTP API events, invocation scope, throttling, and runtime-secret permissions.
- GitHub OIDC audience, exact subjects, existing-provider reuse, and invalid subject rejection.
- Cloudflare owned-domain zones, DNS constraints, assets mapping, and static/SPA behavior.
- Example compositions, including policy and security-group relationships without dependency cycles.
- Unknown resource references in optional IAM policies and reused OIDC providers, using real Terraform values that remain unknown during planning.

## Run locally

```bash
make init
make test
```

Profile roots have their own `tests/profile.tftest.hcl`. Child-module resources are not visible to test assertions, so profile roots expose the roles, secrets, and subnets they configure as outputs for the tests to check.

The shared files under `tests/aws` and `tests/cloudflare` contain fabricated account IDs, ARNs, domain names, and computed attributes. They do not contain secret values. Plan-time mock overrides make output assertions deterministic.

## Limits

Mocks substitute provider behavior. Validation checks schema compatibility, while mocked tests check Terraform configuration and wiring. Neither proves account permissions, service availability, runtime behavior, TLS/DNS activation, image compatibility, provider upload behavior, or actual asset-change redeployment.

Verify those behaviors on real projects with separately approved nonproduction environments (a Phase 4 follow-up; the profiles are validated offline only). Keep local tests mocked; add live validation as an explicit separate workflow rather than giving local checks cloud credentials.
