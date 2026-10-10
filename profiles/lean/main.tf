provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {}

data "aws_caller_identity" "current" {}

locals {
  web_origin = "https://${var.web_hostname}"
}

# Web: Cloudflare Workers static assets on an owned domain.
module "domain" {
  count = var.existing_zone_id == null ? 1 : 0

  source     = "../../cloudflare/domain"
  account_id = var.cloudflare_account_id
  domains    = [var.domain]
}

module "web" {
  source           = "../../cloudflare/static-site"
  account_id       = var.cloudflare_account_id
  name             = "${var.project_name}-web"
  assets_directory = var.web_assets_directory
  spa_mode         = true
  custom_domains   = { (var.web_hostname) = coalesce(var.existing_zone_id, try(module.domain[0].zone_ids[var.domain], null)) }
}

# API: FastAPI container on Lambda behind API Gateway.
module "repository" {
  source = "../../aws/ecr"
  name   = var.project_name
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
        ArnLike      = { "aws:SourceArn" = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${var.project_name}" }
      }
    }]
  })
}

locals {
  api_environment = {
    APP_ENV                         = "prod"
    PERSISTENCE_DRIVER              = "postgresql"
    POSTGRES_HOST                   = var.postgres_host
    POSTGRES_PORT                   = tostring(var.postgres_port)
    POSTGRES_DB                     = var.postgres_database
    POSTGRES_SSL_MODE               = "require"
    POSTGRES_POOL_MODE              = "null"
    POSTGRES_CREDENTIALS_SECRET_ARN = var.database_secret_arn
    CORS_ALLOWED_ORIGINS            = local.web_origin
  }
}

module "api" {
  source      = "../../aws/lambda-fastapi"
  name        = var.project_name
  image_uri   = var.api_image_uri
  environment = local.api_environment
  secret_arns = [var.database_secret_arn]
  depends_on  = [aws_ecr_repository_policy.lambda]
}

# CI: GitHub Actions pushes images to ECR from one environment.
locals {
  github_roles = {
    ecr-push = {
      subjects = ["repo:${var.github_repository}:environment:${var.github_environment}"]
      policy_json = jsonencode({
        Version = "2012-10-17"
        Statement = [
          { Effect = "Allow", Action = ["ecr:GetAuthorizationToken"], Resource = "*" },
          {
            Effect = "Allow"
            Action = [
              "ecr:BatchCheckLayerAvailability",
              "ecr:InitiateLayerUpload",
              "ecr:UploadLayerPart",
              "ecr:CompleteLayerUpload",
              "ecr:PutImage"
            ]
            Resource = module.repository.repository_arn
          }
        ]
      })
    }
  }
}

module "github" {
  source                = "../../aws/github-oidc"
  name                  = var.project_name
  create_provider       = var.create_github_provider
  existing_provider_arn = var.existing_github_provider_arn
  roles                 = local.github_roles
}
