# Architecture

The repository is a module library. Consuming roots compose resources and own providers, credentials, environment configuration, and state.

## Ownership

| Concern | Owner |
|---|---|
| Reusable resources, inputs, outputs, and defaults | AWS or Cloudflare library module |
| Provider region/account selection | Consuming root |
| Backend, locking, and environment isolation | Consuming root |
| S3 bucket policy | Consuming root; one policy combining all statements |
| ECR Lambda retrieval policy | Consuming root |
| Additional database egress | Consuming root |
| Application build, image publishing, migrations, and runtime authentication | Application delivery workflow |
| Worker assets and custom-domain binding | Cloudflare static-site module |
| Registrar activation and GitHub environment restrictions | Account/repository administrator |

S3 exposes its regional REST endpoint. CloudFront consumes that output; the root policy consumes both modules' outputs. This avoids reciprocal dependencies. Database access follows the same pattern: RDS accepts the ECS task security-group ID, while the root connects task egress to the database security group.

## Profiles

The [composition examples](../examples/README.md) exercise module wiring. `static`, `lean`, and `enterprise` deployment profiles require real projects and remain Phase 4 work. No cost target, deployment readiness, or cloud permissions have been established by mocked tests.

## Secrets and artifacts

RDS manages its password in Secrets Manager. ECS uses secret references; Lambda applications retrieve authorized secrets at runtime. Terraform does not read secret versions. IAM policy extensions remain explicit and caller-reviewed.

Images are prebuilt and digest-pinned. ECR retains tagged images; active digests must remain tagged so untagged-image retention does not remove them. Cloudflare assets must exist before planning, and Terraform is their single deployment owner.

See [ADRs](adr/README.md) for packaging and ownership decisions.
