mock_provider "aws" {
  source          = "../../tests/aws"
  override_during = plan
}

variables {
  image_uri           = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example-api@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
  postgres_version    = "17.7"
}

override_resource {
  target          = module.service.aws_security_group.task
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

run "private_container_database_wiring" {
  command = plan
  assert {
    condition     = aws_vpc_security_group_egress_rule.database.security_group_id == module.service.task_security_group_id && aws_vpc_security_group_egress_rule.database.referenced_security_group_id == module.database.security_group_id
    error_message = "Wire PostgreSQL egress to the task and database security groups without a module cycle."
  }
  assert {
    condition     = aws_vpc_security_group_egress_rule.database.from_port == 5432 && aws_vpc_security_group_egress_rule.database.to_port == 5432
    error_message = "Restrict database egress to PostgreSQL."
  }
}
