mock_provider "aws" {
  source          = "../../tests/aws"
  override_during = plan
}

variables {
  github_repository = "example-owner/example-repository"
  bucket_arn        = "arn:aws:s3:::example-static"
}

run "role_contract" {
  command = plan
  assert {
    condition     = output.deployment_role_arn == module.github.role_arns["static"]
    error_message = "Expose the deployment role for the consuming workflow."
  }
}
