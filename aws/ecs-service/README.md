# ECS service

Create a private Fargate service behind a public HTTPS ALB, with a cluster, runtime roles, and retained logs.

## Usage

Example from a root two directories below the repository root. Configure the provider and backend in that consuming root; published consumers should pin the repository source to a reviewed commit or release.

```hcl
module "ecs_service" {
  source = "../../aws/ecs-service"
  name = "example-api"
  vpc_id = var.vpc_id
  public_subnet_ids = var.public_subnet_ids
  private_subnet_ids = var.private_subnet_ids
  image_uri = var.image_uri
  image_repository_arn = var.image_repository_arn
  acm_certificate_arn = var.acm_certificate_arn
}
```

## Inputs

| Name | Type | Default | Meaning |
|---|---|---|---|
| `name` | `string` | Required | Resource name prefix; use lowercase letters, digits, and hyphens. |
| `tags` | `map(string)` | `{}` | Tags attached to taggable AWS resources. |
| `vpc_id` | `string` | Required | VPC containing the ALB and Fargate subnets. |
| `public_subnet_ids` | `list(string)` | Required | Public ALB subnet IDs in at least two availability zones. |
| `private_subnet_ids` | `list(string)` | Required | Private subnet IDs in at least two availability zones. |
| `image_uri` | `string` | Required | Prebuilt private ECR image URI pinned to a SHA-256 digest. |
| `image_repository_arn` | `string` | Required | ECR repository ARN allowed in the execution role pull policy. |
| `acm_certificate_arn` | `string` | Required | Validated ACM certificate in the ALB provider region. |
| `container_port` | `number` | `8080` | Application listening port. |
| `health_check_path` | `string` | `"/health/ready"` | ALB readiness endpoint returning HTTP 200. |
| `task_size` | `object({ cpu = number, memory = number })` | `{ cpu = 256, memory = 512 }` | Fargate CPU units and memory in MiB; supports 0.25–4 vCPU configurations. |
| `cpu_architecture` | `string` | `"X86_64"` | Architecture matching the prebuilt image. |
| `desired_count` | `number` | `1` | Number of Fargate tasks. |
| `allowed_ingress_cidrs` | `set(string)` | `["0.0.0.0/0"]` | IPv4 CIDRs allowed to reach the ALB HTTP redirect and HTTPS listener. |
| `environment` | `map(string)` | `{}` | Nonsecret application environment variables; never pass credentials here. |
| `secret_arns` | `map(string)` | `{}` | Container environment names mapped to Secrets Manager secret ARNs; no secret values or JSON-key suffixes. |
| `task_policy` | `object({ policy_json = string })` | `null` | Optional scoped task policy object; its presence must be known at plan time, but policy_json may include new resource ARNs. |
| `log_retention_days` | `number` | `30` | CloudWatch log retention in days. |

## Outputs

| Name | Meaning |
|---|---|
| `cluster_arn` | ECS cluster ARN. |
| `service_name` | ECS service name. |
| `task_security_group_id` | Task security group ID for explicit database access and additional egress rules. |
| `task_role_arn` | Application task role ARN. |
| `execution_role_name` | Execution role name for caller-owned customer-managed KMS decryption policies, when required. |
| `load_balancer_dns_name` | ALB DNS name; use a DNS alias matching the supplied certificate for HTTPS. |
| `load_balancer_zone_id` | ALB hosted zone ID for DNS aliases. |

## Operational constraints

Supply a validated ACM certificate in the provider region and configure a hostname covered by that certificate. Tasks use private subnets without public addresses. Default task egress allows HTTPS; add caller-owned security-group egress rules for PostgreSQL or other application traffic. NAT or service endpoints are required for image pulls and AWS API access. The filesystem is read-only, so the supplied image must support this. secret_arns accepts complete Secrets Manager ARNs and injects the whole secret at task startup; it does not accept secret values, SSM parameters, or JSON-key suffixes. Customer-managed KMS decryption for execution-time secrets requires a caller-owned execution-role policy. task_policy.policy_json applies to the application task role, not the execution role.

## Verification

Run the repository checks in [development](../../docs/development.md). Tests use plan-only provider mocks; they do not establish deployment or runtime correctness. See [deployment prerequisites](../../docs/deployment.md).
