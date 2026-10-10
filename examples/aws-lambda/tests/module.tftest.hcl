mock_provider "aws" {
  source          = "../../tests/aws"
  override_during = plan
}

variables {
  image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example-api@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

run "scoped_image_retrieval" {
  command = plan
  assert {
    condition     = jsondecode(aws_ecr_repository_policy.lambda.policy).Statement[0].Principal.Service == "lambda.amazonaws.com" && jsondecode(aws_ecr_repository_policy.lambda.policy).Statement[0].Condition.StringEquals["aws:SourceAccount"] == "123456789012"
    error_message = "Limit ECR access to Lambda in the deployment account."
  }
  assert {
    condition     = jsondecode(aws_ecr_repository_policy.lambda.policy).Statement[0].Condition.ArnLike["aws:SourceArn"] == module.api.function_arn
    error_message = "Limit image retrieval to this function."
  }
}
