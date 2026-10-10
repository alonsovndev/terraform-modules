mock_provider "aws" {
  source          = "../../tests/aws"
  override_during = plan
}

variables {
  name      = "example-api"
  image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example-api@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

run "image_http_api_adapter" {
  command = plan
  assert {
    condition     = aws_lambda_function.this.package_type == "Image" && aws_lambda_function.this.image_uri == var.image_uri && one(aws_lambda_function.this.environment).variables["AWS_LWA_PORT"] == "8080"
    error_message = "Use the caller image and Lambda Web Adapter configuration."
  }
  assert {
    condition     = one(aws_lambda_function.this.environment).variables["AWS_LWA_READINESS_CHECK_PATH"] == "/health/ready" && aws_apigatewayv2_integration.this.payload_format_version == "2.0"
    error_message = "Use readiness checks and HTTP API v2 events."
  }
  assert {
    condition     = aws_lambda_permission.api.source_arn == "${aws_apigatewayv2_api.this.execution_arn}/*/*" && length(jsondecode(aws_iam_role_policy.runtime.policy).Statement) == 1
    error_message = "Limit invocation to this API and grant only log permissions by default."
  }
  assert {
    condition     = one(aws_apigatewayv2_stage.this.default_route_settings).throttling_rate_limit == 5
    error_message = "Apply an explicit default request throttle."
  }
}

run "runtime_secret_permissions" {
  command = plan
  variables {
    secret_arns = ["arn:aws:secretsmanager:us-east-1:123456789012:secret:example-000000"]
  }
  assert {
    condition     = jsondecode(aws_iam_role_policy.runtime.policy).Statement[1].Action == ["secretsmanager:GetSecretValue"] && toset(jsondecode(aws_iam_role_policy.runtime.policy).Statement[1].Resource) == var.secret_arns
    error_message = "Runtime secret access must be explicitly scoped."
  }
}

run "integration_timeout_limit" {
  command = plan
  variables {
    timeout_seconds = 31
  }
  expect_failures = [var.timeout_seconds]
}

run "wrong_image_region" {
  command = plan
  variables {
    image_uri = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/example-api@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }
  expect_failures = [aws_lambda_function.this]
}

run "mutable_image_rejected" {
  command = plan
  variables {
    image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example-api:latest"
  }
  expect_failures = [var.image_uri]
}

run "maximum_name_iam_prefix" {
  command = plan
  variables {
    name = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }
  assert {
    condition     = length(aws_iam_role.this.name_prefix) <= 38
    error_message = "Maximum-length function names must leave room for IAM's generated role-name suffix."
  }
}

run "adapter_environment_cannot_be_overridden" {
  command = plan
  variables {
    environment = { AWS_LWA_PORT = "9000" }
  }
  expect_failures = [var.environment]
}
