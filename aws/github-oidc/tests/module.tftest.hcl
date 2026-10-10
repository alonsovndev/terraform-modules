mock_provider "aws" {
  source          = "../../tests/aws"
  override_during = plan
}

variables {
  name  = "example-github"
  roles = { static = { subjects = ["repo:example-owner/example-repository:ref:refs/heads/main"], policy_json = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = ["s3:ListBucket"], Resource = "arn:aws:s3:::example-static" }] }) } }
}

run "exact_repository_subject_and_audience" {
  command = plan
  assert {
    condition     = jsondecode(aws_iam_role.this["static"].assume_role_policy).Statement[0].Condition.StringEquals["token.actions.githubusercontent.com:aud"] == "sts.amazonaws.com"
    error_message = "Require the AWS STS audience."
  }
  assert {
    condition     = jsondecode(aws_iam_role.this["static"].assume_role_policy).Statement[0].Condition.StringEquals["token.actions.githubusercontent.com:sub"] == ["repo:example-owner/example-repository:ref:refs/heads/main"]
    error_message = "Trust only the exact caller subjects."
  }
  assert {
    condition     = jsondecode(aws_iam_role_policy.this["static"].policy).Statement[0].Resource == "arn:aws:s3:::example-static"
    error_message = "Preserve the caller-scoped permission policy."
  }
}

run "reuse_account_provider" {
  command = plan
  variables {
    create_provider       = false
    existing_provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
  }
  assert {
    condition     = length(aws_iam_openid_connect_provider.this) == 0 && output.provider_arn == var.existing_provider_arn
    error_message = "Reuse the existing account provider without attempting to recreate it."
  }
}

run "environment_subject" {
  command = plan
  variables {
    roles = { static = { subjects = ["repo:example-owner/example-repository:environment:production"], policy_json = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = ["s3:ListBucket"], Resource = "arn:aws:s3:::example-static" }] }) } }
  }
  assert {
    condition     = jsondecode(aws_iam_role.this["static"].assume_role_policy).Statement[0].Condition.StringEquals["token.actions.githubusercontent.com:sub"] == ["repo:example-owner/example-repository:environment:production"]
    error_message = "Support an exact GitHub environment subject."
  }
}

run "wildcard_subject_rejected" {
  command = plan
  variables {
    roles = { static = { subjects = ["repo:example-owner/example-repository:ref:refs/heads/*"], policy_json = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = ["s3:ListBucket"], Resource = "arn:aws:s3:::example-static" }] }) } }
  }
  expect_failures = [var.roles]
}

run "pull_request_subject_rejected" {
  command = plan
  variables {
    roles = { static = { subjects = ["repo:example-owner/example-repository:pull_request"], policy_json = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = ["s3:ListBucket"], Resource = "arn:aws:s3:::example-static" }] }) } }
  }
  expect_failures = [var.roles]
}

run "reuse_requires_provider_arn" {
  command = plan
  variables {
    create_provider = false
  }
  expect_failures = [var.existing_provider_arn]
}
