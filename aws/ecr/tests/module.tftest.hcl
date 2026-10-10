mock_provider "aws" {
  source          = "../../tests/aws"
  override_during = plan
}

variables {
  name = "example-api"
}

run "immutable_scanned_repository" {
  command = plan
  assert {
    condition     = aws_ecr_repository.this.image_tag_mutability == "IMMUTABLE" && one(aws_ecr_repository.this.image_scanning_configuration).scan_on_push && !aws_ecr_repository.this.force_delete
    error_message = "Repository images must be immutable, scanned, and protected from forced deletion."
  }
  assert {
    condition     = jsondecode(aws_ecr_lifecycle_policy.this.policy).rules[0].selection.tagStatus == "untagged"
    error_message = "Lifecycle rules must preserve tagged deployment images."
  }
}

run "custom_retention" {
  command = plan
  variables {
    untagged_retention_days = 14
  }
  assert {
    condition     = jsondecode(aws_ecr_lifecycle_policy.this.policy).rules[0].selection.countNumber == 14
    error_message = "Use the caller retention period."
  }
}

run "invalid_retention" {
  command = plan
  variables {
    untagged_retention_days = 0
  }
  expect_failures = [var.untagged_retention_days]
}
