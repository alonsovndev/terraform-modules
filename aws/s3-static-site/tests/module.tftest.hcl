mock_provider "aws" {
  source          = "../../tests/aws"
  override_during = plan
}

variables {
  name = "example-static"
}

run "private_encrypted_versioned_bucket" {
  command = plan
  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls && aws_s3_bucket_public_access_block.this.block_public_policy && aws_s3_bucket_public_access_block.this.ignore_public_acls && aws_s3_bucket_public_access_block.this.restrict_public_buckets
    error_message = "Block all public S3 access."
  }
  assert {
    condition     = one(aws_s3_bucket_server_side_encryption_configuration.this.rule).apply_server_side_encryption_by_default[0].sse_algorithm == "AES256"
    error_message = "Enable default server-side encryption."
  }
  assert {
    condition     = one(aws_s3_bucket_versioning.this.versioning_configuration).status == "Enabled" && !aws_s3_bucket.this.force_destroy
    error_message = "Version content and prohibit forced content deletion."
  }
  assert {
    condition     = one(aws_s3_bucket_ownership_controls.this.rule).object_ownership == "BucketOwnerEnforced"
    error_message = "Disable object ACL ownership ambiguity."
  }
}

run "invalid_bucket_name" {
  command = plan
  variables {
    name = "invalid.bucket"
  }
  expect_failures = [var.name]
}
