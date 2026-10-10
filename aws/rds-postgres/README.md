# RDS PostgreSQL

Create encrypted private PostgreSQL with backups, deletion protection, and an RDS-managed master password.

## Usage

Example from a root two directories below the repository root. Configure the provider and backend in that consuming root; published consumers should pin the repository source to a reviewed commit or release.

```hcl
module "rds_postgres" {
  source = "../../aws/rds-postgres"
  name = "example-postgres"
  vpc_id = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  client_security_group_ids = { api = var.api_security_group_id }
  engine_version = var.postgres_version
  database_name = "application"
  final_snapshot_identifier = var.final_snapshot_identifier
}
```

## Inputs

| Name | Type | Default | Meaning |
|---|---|---|---|
| `name` | `string` | Required | Resource name prefix; use lowercase letters, digits, and hyphens. |
| `tags` | `map(string)` | `{}` | Tags attached to taggable AWS resources. |
| `vpc_id` | `string` | Required | VPC containing the private database subnets. |
| `private_subnet_ids` | `list(string)` | Required | Private subnet IDs in at least two availability zones. |
| `client_security_group_ids` | `map(string)` | `{}` | Allowed client security group IDs keyed by stable caller-chosen names. |
| `engine_version` | `string` | Required | PostgreSQL engine version available in the selected region. |
| `instance_class` | `string` | `"db.t4g.micro"` | RDS PostgreSQL instance class available in the selected region. |
| `allocated_storage_gib` | `number` | `20` | Allocated gp3 storage in GiB. |
| `database_name` | `string` | Required | Initial database name. |
| `master_username` | `string` | `"appadmin"` | Initial PostgreSQL master username; applications should use separate least-privilege users. |
| `multi_az` | `bool` | `false` | Enable the paid Multi-AZ standby. |
| `backup_retention_days` | `number` | `7` | Automatic backup retention in days; backups cannot be disabled. |
| `deletion_protection` | `bool` | `true` | Protect the instance against deletion; disable only for an explicitly approved teardown. |
| `final_snapshot_identifier` | `string` | Required | Unique final snapshot name for a future approved teardown; select a new name if a snapshot already exists. |

## Outputs

| Name | Meaning |
|---|---|
| `endpoint` | PostgreSQL endpoint including port; no credentials. |
| `database_name` | Initial database name. |
| `master_secret_arn` | ARN of the RDS-managed master credential secret; its value is never retrieved. |
| `security_group_id` | Database security group ID. |

## Operational constraints

Applications should use separately provisioned least-privilege database users. Terraform never retrieves the master password; master_secret_arn identifies the managed secret. client_security_group_ids uses stable keys so newly created client IDs can remain unknown during planning. Subnets must cover two availability zones; a single-AZ database remains the default to avoid unrequested standby cost. Verify engine and instance availability in the selected region. A final snapshot is mandatory, and its identifier must be unique at teardown. Disable deletion protection only after explicit approval.

## Verification

Run the repository checks in [development](../../docs/development.md). Tests use plan-only provider mocks; they do not establish deployment or runtime correctness. See [deployment prerequisites](../../docs/deployment.md).
