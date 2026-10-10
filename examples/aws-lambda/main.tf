provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

variable "image_uri" {
  description = "Prebuilt Lambda Web Adapter-compatible ECR image digest from example-api in us-east-1."
  type        = string
}

module "repository" {
  source = "../../aws/ecr"
  name   = "example-api"
}

resource "aws_ecr_repository_policy" "lambda" {
  repository = module.repository.repository_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "LambdaImageRetrieval"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer"]
      Condition = {
        StringEquals = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id }
        ArnLike      = { "aws:SourceArn" = "arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:example-api" }
      }
    }]
  })
}

module "api" {
  source      = "../../aws/lambda-fastapi"
  name        = "example-api"
  image_uri   = var.image_uri
  environment = { APP_ENV = "prod" }
  depends_on  = [aws_ecr_repository_policy.lambda]
}

output "api_endpoint" {
  description = "Public HTTP API URL; application authentication must be implemented separately."
  value       = module.api.api_endpoint
}
