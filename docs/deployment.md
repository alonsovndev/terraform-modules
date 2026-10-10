# Deployment prerequisites

These modules have local validation and mocked tests. They are not deployed by this repository. Each real project needs an approved environment, reviewed plan, and independently configured state before deployment.

## Consuming root

Configure provider credentials outside Terraform source. Prefer GitHub OIDC for AWS automation and an appropriately scoped `CLOUDFLARE_API_TOKEN` for Cloudflare. Never commit tokens, real variable files, state, or saved plans.

Own an encrypted remote backend with state locking and separate state per project/environment. No backend or environment migration is supplied here. Account IDs, owners, state locations, and rollout dates remain project-specific `TBD` values.

## AWS prerequisites

| Composition | Requirements |
|---|---|
| Containers | Two availability zones, private-task egress, a validated regional ACM certificate, a matching application hostname, and a prebuilt compatible ECR image |
| PostgreSQL | Supported regional engine/version and instance class; nonoverlapping subnets; separate application-user provisioning and migrations |
| Static hosting | Globally unique bucket name, one root-owned TLS/OAC bucket policy, separate asset publishing, and cache invalidation strategy |
| Lambda | ECR image in the Lambda region, correct architecture and Web Adapter, read-only filesystem support, repository pull permission, and application-owned API authentication |
| OIDC | One account-wide provider, exact subject allowlists, reviewed permission policies, and GitHub environment branch/reviewer restrictions when used |

The container and Lambda examples manage their ECR repository. For a first deployment, approve an ECR-only bootstrap plan in the same root state, then build and push an immutable image tag and record its digest before approving the complete application plan. Do not create the same repository under a second state. Terraform does not build images or run application migrations.

The container example demonstrates network and database wiring, not automatic integration of an application with master credentials. Configure the real application's database settings and least-privilege user separately. The supplied image must support a read-only filesystem. Runtime environment values must remain nonsecret.

NAT gateways, ALB, ECS, RDS, logs, backups, and transfer have recurring costs. The enterprise example is not intended to meet the lean profile's operating-cost target. Exact costs and account-specific free allowances remain `TBD`.

## Cloudflare prerequisites

Own the domain before creating a zone. Existing zones should be supplied by ID or imported into the chosen root only through a separately approved import procedure. Update registrar nameservers manually and confirm zone activation.

Build assets before planning. Let Terraform own the Worker and custom-domain resources; do not redeploy the same Worker through another deployment tool. Workers custom domains manage their own hostname routing, so do not also manage those hostnames in the DNS-record module. Confirm certificate issuance, DNS activation, security headers, ordinary 404 behavior, SPA routing when enabled, and content-change deployment with a real project.

API-token permissions depend on the resources used. Grant account-scoped Workers script permissions and zone-scoped DNS/zone permissions as required; confirm the exact custom-domain and zone-creation permissions with the account administrator. Do not use a global API key.

## Review and recovery

Before deployment, review the actual plan for replacements, deletes, IAM permissions, and public exposure. Require explicit target-environment approval before apply, import, state operations, backend migration, or teardown.

Use an approved previous image digest or application artifact to recover a failed runtime deployment. ECS has deployment circuit-breaker rollback; this does not roll back databases or Terraform changes. RDS teardown requires disabling deletion protection through review and selecting a unique final snapshot identifier. Cloudflare zones are protected with `prevent_destroy`.

State backups and any future resource-address migration belong to the consuming project. No production rollout or recovery procedure is claimed without a target project.
