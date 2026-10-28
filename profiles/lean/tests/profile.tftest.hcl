mock_provider "aws" {
  source          = "../../tests/aws"
  override_during = plan
}

mock_provider "cloudflare" {
  source          = "../../tests/cloudflare"
  override_during = plan
}

variables {
  project_name          = "example-app"
  cloudflare_account_id = "00000000000000000000000000000000"
  domain                = "example.com"
  web_hostname          = "app.example.com"
  web_assets_directory  = "../../examples/cloudflare-static/assets"
  api_image_uri         = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example-app@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  database_secret_arn   = "arn:aws:secretsmanager:us-east-1:123456789012:secret:example-app-database-AbCdEf"
  postgres_host         = "aws-0-us-east-1.pooler.supabase.com"
  github_repository     = "example-owner/example-api"
}

run "api_is_wired_for_a_pooler_without_credentials" {
  command = plan
  assert {
    condition     = output.api_environment["POSTGRES_POOL_MODE"] == "null" && output.api_environment["POSTGRES_SSL_MODE"] == "require" && output.api_environment["POSTGRES_PORT"] == "6543"
    error_message = "Use SSL and unpooled connections behind the Supabase pooler."
  }
  assert {
    condition     = !contains(keys(output.api_environment), "POSTGRES_PASSWORD") && !contains(keys(output.api_environment), "POSTGRES_CREDENTIALS_JSON") && output.api_environment["POSTGRES_CREDENTIALS_SECRET_ARN"] == var.database_secret_arn
    error_message = "Pass only the secret ARN; never put the database password in the Lambda environment."
  }
  assert {
    condition     = output.api_environment["CORS_ALLOWED_ORIGINS"] == "https://app.example.com"
    error_message = "Allow only the web app origin."
  }
}

run "web_and_images_are_bound_to_this_project" {
  command = plan
  assert {
    condition     = output.site_urls["app.example.com"] == "https://app.example.com" && length(output.nameservers) == 2
    error_message = "Bind the web hostname and return activation nameservers."
  }
  assert {
    condition     = jsondecode(aws_ecr_repository_policy.lambda.policy).Statement[0].Condition.ArnLike["aws:SourceArn"] == "arn:aws:lambda:us-east-1:123456789012:function:example-app"
    error_message = "Limit image retrieval to this project's function."
  }
}

run "ci_role_trusts_one_repository_environment" {
  command = plan
  assert {
    condition     = output.github_role_subjects["ecr-push"] == ["repo:example-owner/example-api:environment:production"]
    error_message = "Trust exactly one repository environment subject."
  }
  assert {
    condition     = output.github_role_policies["ecr-push"].Statement[1].Resource == module.repository.repository_arn
    error_message = "Limit image pushes to this project's repository."
  }
  assert {
    condition     = output.ecr_push_role_arn == module.github.role_arns["ecr-push"]
    error_message = "Expose the image push role for the docker-push workflow."
  }
}

run "reuses_an_existing_zone" {
  command = plan
  variables {
    existing_zone_id = "11111111111111111111111111111111"
  }
  assert {
    condition     = length(module.domain) == 0 && length(output.nameservers) == 0
    error_message = "Do not create a zone when an existing zone ID is supplied."
  }
}

run "rejects_a_hostname_outside_the_domain" {
  command = plan
  variables {
    web_hostname = "app.other.org"
  }
  expect_failures = [var.web_hostname]
}
