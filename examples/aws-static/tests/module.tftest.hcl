mock_provider "aws" {
  source          = "../../tests/aws"
  override_during = plan
}

variables {
  bucket_name = "example-static"
}

run "single_owner_bucket_policy" {
  command = plan
  assert {
    condition     = jsondecode(aws_s3_bucket_policy.this.policy).Statement[0].Condition.Bool["aws:SecureTransport"] == "false" && jsondecode(aws_s3_bucket_policy.this.policy).Statement[0].Effect == "Deny"
    error_message = "The composition must deny insecure bucket transport."
  }
  assert {
    condition     = jsondecode(aws_s3_bucket_policy.this.policy).Statement[1].Condition.StringEquals["AWS:SourceArn"] == module.cdn.distribution_arn && jsondecode(aws_s3_bucket_policy.this.policy).Statement[1].Action == "s3:GetObject"
    error_message = "Grant CloudFront read access only from this distribution."
  }
}
