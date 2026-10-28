mock_provider "aws" {
  source          = "../../tests/aws"
  override_during = plan
}

variables {
  project_name              = "example-app"
  availability_zones        = ["us-east-1a", "us-east-1b"]
  api_image_uri             = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example-app@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  api_certificate_arn       = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
  postgres_version          = "17.7"
  final_snapshot_identifier = "example-app-postgres-final-replace-before-teardown"
  web_bucket_name           = "example-app-web"
  github_repository         = "example-owner/example-app"
}

override_resource {
  target          = module.repository.aws_ecr_repository.this
  override_during = plan
  values = {
    arn            = "arn:aws:ecr:us-east-1:123456789012:repository/example-app"
    repository_url = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example-app"
  }
}

override_resource {
  target          = module.api.aws_security_group.task
  override_during = plan
  values          = { id = "sg-00000000000000002" }
}

override_resource {
  target          = module.database.aws_security_group.this
  override_during = plan
  values          = { id = "sg-00000000000000003" }
}

override_resource {
  target          = module.network.aws_subnet.public["us-east-1a"]
  override_during = plan
  values          = { id = "subnet-00000000000000001" }
}

override_resource {
  target          = module.network.aws_subnet.public["us-east-1b"]
  override_during = plan
  values          = { id = "subnet-00000000000000002" }
}

override_resource {
  target          = module.network.aws_subnet.private["us-east-1a"]
  override_during = plan
  values          = { id = "subnet-00000000000000003" }
}

override_resource {
  target          = module.network.aws_subnet.private["us-east-1b"]
  override_during = plan
  values          = { id = "subnet-00000000000000004" }
}

run "api_reads_database_credentials_from_secrets_manager" {
  command = plan
  assert {
    condition     = !contains(keys(output.api_environment), "POSTGRES_PASSWORD") && !contains(keys(output.api_environment), "POSTGRES_CREDENTIALS_JSON")
    error_message = "Inject credentials through ECS secrets, never the plain environment."
  }
  assert {
    condition     = output.api_environment["POSTGRES_SSL_MODE"] == "require" && output.api_environment["APP_ENV"] == "prod"
    error_message = "Require SSL to RDS in the prod profile."
  }
  assert {
    condition     = output.api_secret_arns == { POSTGRES_CREDENTIALS_JSON = module.database.master_secret_arn }
    error_message = "Inject the RDS-managed secret as the only container secret."
  }
  assert {
    condition     = output.api_environment["CORS_ALLOWED_ORIGINS"] == "https://${module.cdn.domain_name}"
    error_message = "Without aliases, allow the default CloudFront hostname."
  }
}

run "database_is_reachable_only_from_the_api_tasks" {
  command = plan
  assert {
    condition     = aws_vpc_security_group_egress_rule.database.security_group_id == module.api.task_security_group_id && aws_vpc_security_group_egress_rule.database.referenced_security_group_id == module.database.security_group_id
    error_message = "Wire PostgreSQL egress between the task and database security groups."
  }
  assert {
    condition     = aws_vpc_security_group_egress_rule.database.from_port == 5432 && aws_vpc_security_group_egress_rule.database.to_port == 5432
    error_message = "Restrict database egress to PostgreSQL."
  }
}

run "subnets_are_derived_from_the_vpc_cidr" {
  command = plan
  assert {
    condition     = output.subnet_cidrs["us-east-1a"].public_cidr == "10.20.0.0/24" && output.subnet_cidrs["us-east-1b"].public_cidr == "10.20.1.0/24"
    error_message = "Place public subnets at the start of the VPC range."
  }
  assert {
    condition     = output.subnet_cidrs["us-east-1a"].private_cidr == "10.20.10.0/24" && output.subnet_cidrs["us-east-1b"].private_cidr == "10.20.11.0/24"
    error_message = "Place private subnets at offset 10."
  }
}

run "web_bucket_only_serves_cloudfront_over_tls" {
  command = plan
  assert {
    condition     = jsondecode(aws_s3_bucket_policy.web.policy).Statement[0].Effect == "Deny" && jsondecode(aws_s3_bucket_policy.web.policy).Statement[0].Condition.Bool["aws:SecureTransport"] == "false"
    error_message = "Deny insecure bucket transport."
  }
  assert {
    condition     = jsondecode(aws_s3_bucket_policy.web.policy).Statement[1].Condition.StringEquals["AWS:SourceArn"] == module.cdn.distribution_arn
    error_message = "Grant read access only to this distribution."
  }
}

run "ci_roles_are_limited_to_one_repository_environment" {
  command = plan
  assert {
    condition     = length(output.github_role_arns) == 2
    error_message = "Create only the image push and web publish roles."
  }
  assert {
    condition     = output.github_role_subjects == { ecr-push = ["repo:example-owner/example-app:environment:production"], web-publish = ["repo:example-owner/example-app:environment:production"] }
    error_message = "Trust exactly one repository environment subject."
  }
  assert {
    condition     = output.github_role_policies["ecr-push"].Statement[1].Resource == module.repository.repository_arn
    error_message = "Limit image pushes to this project's repository."
  }
  assert {
    condition     = output.github_role_policies["web-publish"].Statement[2].Resource == module.cdn.distribution_arn
    error_message = "Limit invalidations to this distribution."
  }
}

run "uses_a_custom_web_hostname_for_cors" {
  command = plan
  variables {
    web_aliases         = ["app.example.com"]
    web_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/11111111-1111-1111-1111-111111111111"
  }
  assert {
    condition     = output.api_environment["CORS_ALLOWED_ORIGINS"] == "https://app.example.com"
    error_message = "Allow only the configured web hostname."
  }
}

run "allows_every_configured_web_hostname" {
  command = plan
  variables {
    web_aliases         = ["b.example.com", "a.example.com"]
    web_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/11111111-1111-1111-1111-111111111111"
  }
  assert {
    condition     = output.api_environment["CORS_ALLOWED_ORIGINS"] == "https://a.example.com,https://b.example.com"
    error_message = "Allow each configured web hostname."
  }
}

run "rejects_a_vpc_too_small_to_split" {
  command = plan
  variables {
    vpc_cidr = "10.20.0.0/22"
  }
  expect_failures = [var.vpc_cidr]
}

run "rejects_a_single_availability_zone" {
  command = plan
  variables {
    availability_zones = ["us-east-1a"]
  }
  expect_failures = [var.availability_zones]
}
