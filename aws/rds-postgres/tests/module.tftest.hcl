mock_provider "aws" {
  source          = "../../tests/aws"
  override_during = plan
}

variables {
  name                      = "example-postgres"
  vpc_id                    = "vpc-00000000000000001"
  private_subnet_ids        = ["subnet-00000000000000001", "subnet-00000000000000002"]
  client_security_group_ids = { api = "sg-00000000000000001" }
  engine_version            = "17.7"
  database_name             = "application"
  final_snapshot_identifier = "example-postgres-final"
}

run "private_managed_credentials" {
  command = plan
  assert {
    condition     = aws_db_instance.this.storage_encrypted && !aws_db_instance.this.publicly_accessible && aws_db_instance.this.manage_master_user_password
    error_message = "The database must be private and encrypted, with managed credentials."
  }
  assert {
    condition     = aws_db_instance.this.deletion_protection && !aws_db_instance.this.skip_final_snapshot && aws_db_instance.this.backup_retention_period == 7
    error_message = "Enable deletion protection, final snapshots, and backups."
  }
  assert {
    condition     = aws_vpc_security_group_ingress_rule.postgres["api"].referenced_security_group_id == "sg-00000000000000001" && aws_vpc_security_group_ingress_rule.postgres["api"].from_port == 5432
    error_message = "Only the specified client security group may reach PostgreSQL."
  }
  assert {
    condition     = startswith(output.master_secret_arn, "arn:aws:secretsmanager:")
    error_message = "Output only the credential secret ARN."
  }
}

run "backups_cannot_be_disabled" {
  command = plan
  variables {
    backup_retention_days = 0
  }
  expect_failures = [var.backup_retention_days]
}

run "reserved_username" {
  command = plan
  variables {
    master_username = "postgres"
  }
  expect_failures = [var.master_username]
}

run "single_subnet_rejected" {
  command = plan
  variables {
    private_subnet_ids = ["subnet-00000000000000001"]
  }
  expect_failures = [var.private_subnet_ids]
}

run "consecutive_hyphens_rejected" {
  command = plan
  variables {
    name = "example--postgres"
  }
  expect_failures = [var.name]
}
