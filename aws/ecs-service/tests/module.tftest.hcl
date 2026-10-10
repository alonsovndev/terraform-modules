mock_provider "aws" {
  source          = "../../tests/aws"
  override_during = plan
}

variables {
  name                 = "example-api"
  vpc_id               = "vpc-00000000000000001"
  public_subnet_ids    = ["subnet-00000000000000001", "subnet-00000000000000002"]
  private_subnet_ids   = ["subnet-00000000000000003", "subnet-00000000000000004"]
  image_uri            = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example-api@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  image_repository_arn = "arn:aws:ecr:us-east-1:123456789012:repository/example-api"
  acm_certificate_arn  = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
}

override_resource {
  target          = aws_security_group.load_balancer
  override_during = plan
  values          = { id = "sg-00000000000000001" }
}

override_resource {
  target          = aws_security_group.task
  override_during = plan
  values          = { id = "sg-00000000000000002" }
}

run "private_https_service" {
  command = plan
  assert {
    condition     = !one(aws_ecs_service.this.network_configuration).assign_public_ip && one(aws_ecs_service.this.network_configuration).subnets == toset(var.private_subnet_ids)
    error_message = "Tasks must use private subnets without public IPs."
  }
  assert {
    condition     = one(one(aws_lb_listener.http.default_action).redirect).protocol == "HTTPS" && aws_lb_listener.https.protocol == "HTTPS"
    error_message = "Serve HTTPS and redirect HTTP."
  }
  assert {
    condition     = jsondecode(aws_ecs_task_definition.this.container_definitions)[0].readonlyRootFilesystem && length(aws_iam_role_policy.task) == 0
    error_message = "Use a read-only task filesystem and no default application permissions."
  }
  assert {
    condition     = aws_vpc_security_group_ingress_rule.application.referenced_security_group_id == aws_security_group.load_balancer.id && aws_vpc_security_group_egress_rule.task_https.from_port == 443 && aws_vpc_security_group_egress_rule.task_https.to_port == 443
    error_message = "Restrict task ingress to the ALB and default egress to HTTPS."
  }
  assert {
    condition     = one(aws_ecs_service.this.deployment_circuit_breaker).rollback
    error_message = "Failed deployments must roll back."
  }
}

run "secret_references_only" {
  command = plan
  variables {
    secret_arns = { APPLICATION_CREDENTIALS = "arn:aws:secretsmanager:us-east-1:123456789012:secret:example-000000" }
  }
  assert {
    condition     = jsondecode(aws_ecs_task_definition.this.container_definitions)[0].secrets[0].valueFrom == var.secret_arns["APPLICATION_CREDENTIALS"] && length(jsondecode(aws_ecs_task_definition.this.container_definitions)[0].environment) == 0
    error_message = "Use secret references without copying credentials into the plain environment."
  }
  assert {
    condition     = jsondecode(aws_iam_role_policy.execution.policy).Statement[3].Resource == [var.secret_arns["APPLICATION_CREDENTIALS"]]
    error_message = "Secret access must be restricted to the supplied ARN."
  }
}

run "unsupported_task_size" {
  command = plan
  variables {
    task_size = { cpu = 256, memory = 4096 }
  }
  expect_failures = [var.task_size]
}

run "mutable_image_rejected" {
  command = plan
  variables {
    image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example-api:latest"
  }
  expect_failures = [var.image_uri]
}

run "duplicate_environment_rejected" {
  command = plan
  variables {
    environment = { APPLICATION_CREDENTIALS = "placeholder" }
    secret_arns = { APPLICATION_CREDENTIALS = "arn:aws:secretsmanager:us-east-1:123456789012:secret:example-000000" }
  }
  expect_failures = [var.secret_arns]
}

run "maximum_name_iam_prefixes" {
  command = plan
  variables {
    name = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }
  assert {
    condition     = length(aws_iam_role.execution.name_prefix) <= 38 && length(aws_iam_role.task.name_prefix) <= 38
    error_message = "Maximum-length service names must leave room for IAM's generated role-name suffix."
  }
}

run "wrong_image_repository_rejected" {
  command = plan
  variables {
    image_repository_arn = "arn:aws:ecr:us-east-1:123456789012:repository/different-api"
  }
  expect_failures = [aws_ecs_task_definition.this]
}
