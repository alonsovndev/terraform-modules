# AWS container example

Compose VPC, ECR, private Fargate/HTTPS ALB, and private PostgreSQL. The root connects task egress to the database security group.

Supply a digest-pinned `image_uri`, a validated `acm_certificate_arn` in `us-east-1`, and a regionally available `postgres_version`. NAT is enabled per availability zone so tasks can pull images and use AWS APIs. This has recurring cost.

The ECR-only bootstrap, image publishing, hostname configuration, application database configuration, database users, and migrations need separate delivery steps. This example does not inject master credentials into the application. See [deployment prerequisites](../../docs/deployment.md).

## Local verification

From the repository root, run `make ci`. The example's mocked test checks task-to-database egress wiring. The underlying module tests check private tasks, NAT, HTTPS, and managed database credentials.
