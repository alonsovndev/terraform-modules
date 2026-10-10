resource "terraform_data" "permission" {
  input = "arn:aws:s3:::example-static"
}

resource "terraform_data" "provider" {
  input = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
}

locals {
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:ListBucket"]
      Resource = terraform_data.permission.output
    }]
  })
  image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example-api@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

module "service" {
  source               = "../../../aws/ecs-service"
  name                 = "example-api"
  vpc_id               = "vpc-00000000000000001"
  public_subnet_ids    = ["subnet-00000000000000001", "subnet-00000000000000002"]
  private_subnet_ids   = ["subnet-00000000000000003", "subnet-00000000000000004"]
  image_uri            = local.image_uri
  image_repository_arn = "arn:aws:ecr:us-east-1:123456789012:repository/example-api"
  acm_certificate_arn  = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
  task_policy          = { policy_json = local.policy_json }
}

module "api" {
  source         = "../../../aws/lambda-fastapi"
  name           = "example-api"
  image_uri      = local.image_uri
  runtime_policy = { policy_json = local.policy_json }
}

module "github" {
  source                = "../../../aws/github-oidc"
  name                  = "example-github"
  create_provider       = false
  existing_provider_arn = terraform_data.provider.output
  roles = {
    static = {
      subjects    = ["repo:example-owner/example-repository:ref:refs/heads/main"]
      policy_json = local.policy_json
    }
  }
}
