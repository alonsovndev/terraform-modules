provider "aws" {
  region = var.aws_region
}

locals {
  subnets = {
    for index, zone in sort(var.availability_zones) : zone => {
      public_cidr  = cidrsubnet(var.vpc_cidr, 8, index)
      private_cidr = cidrsubnet(var.vpc_cidr, 8, index + 10)
    }
  }
  web_origin = length(var.web_aliases) > 0 ? join(",", [for alias in sort(tolist(var.web_aliases)) : "https://${alias}"]) : "https://${module.cdn.domain_name}"
}

module "network" {
  source             = "../../aws/vpc"
  name               = "${var.project_name}-network"
  cidr_block         = var.vpc_cidr
  enable_nat_gateway = var.enable_nat_gateway
  subnets            = local.subnets
}

# Web: private S3 bucket behind CloudFront.
module "bucket" {
  source = "../../aws/s3-static-site"
  name   = var.web_bucket_name
}

module "cdn" {
  source                      = "../../aws/cloudfront"
  name                        = var.project_name
  bucket_regional_domain_name = module.bucket.regional_domain_name
  aliases                     = var.web_aliases
  acm_certificate_arn         = var.web_certificate_arn
  spa_mode                    = true
}

resource "aws_s3_bucket_policy" "web" {
  bucket = module.bucket.bucket_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [module.bucket.bucket_arn, "${module.bucket.bucket_arn}/*"]
        Condition = { Bool = { "aws:SecureTransport" = "false" } }
      },
      {
        Sid       = "AllowCloudFrontRead"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${module.bucket.bucket_arn}/*"
        Condition = { StringEquals = { "AWS:SourceArn" = module.cdn.distribution_arn } }
      }
    ]
  })
}

# API: FastAPI container on ECS Fargate behind an ALB, with PostgreSQL on RDS.
module "repository" {
  source = "../../aws/ecr"
  name   = var.project_name
}

locals {
  api_environment = {
    APP_ENV              = "prod"
    PERSISTENCE_DRIVER   = "postgresql"
    POSTGRES_HOST        = split(":", module.database.endpoint)[0]
    POSTGRES_PORT        = "5432"
    POSTGRES_DB          = module.database.database_name
    POSTGRES_SSL_MODE    = "require"
    CORS_ALLOWED_ORIGINS = local.web_origin
  }
}

locals {
  api_secret_arns = { POSTGRES_CREDENTIALS_JSON = module.database.master_secret_arn }
}

module "api" {
  source                = "../../aws/ecs-service"
  name                  = var.project_name
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = values(module.network.public_subnet_ids)
  private_subnet_ids    = values(module.network.private_subnet_ids)
  image_uri             = var.api_image_uri
  image_repository_arn  = module.repository.repository_arn
  acm_certificate_arn   = var.api_certificate_arn
  health_check_path     = "/health"
  allowed_ingress_cidrs = var.api_allowed_ingress_cidrs
  environment           = local.api_environment
  secret_arns           = { POSTGRES_CREDENTIALS_JSON = module.database.master_secret_arn }
}

module "database" {
  source                    = "../../aws/rds-postgres"
  name                      = "${var.project_name}-postgres"
  vpc_id                    = module.network.vpc_id
  private_subnet_ids        = values(module.network.private_subnet_ids)
  client_security_group_ids = { api = module.api.task_security_group_id }
  engine_version            = var.postgres_version
  database_name             = "application"
  multi_az                  = var.multi_az
  final_snapshot_identifier = var.final_snapshot_identifier
}

resource "aws_vpc_security_group_egress_rule" "database" {
  security_group_id            = module.api.task_security_group_id
  referenced_security_group_id = module.database.security_group_id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

# CI: GitHub Actions pushes images and publishes the web app from one environment.
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
    web-publish = {
      subjects = ["repo:${var.github_repository}:environment:${var.github_environment}"]
      policy_json = jsonencode({
        Version = "2012-10-17"
        Statement = [
          { Effect = "Allow", Action = ["s3:ListBucket"], Resource = module.bucket.bucket_arn },
          { Effect = "Allow", Action = ["s3:PutObject", "s3:DeleteObject"], Resource = "${module.bucket.bucket_arn}/*" },
          { Effect = "Allow", Action = ["cloudfront:CreateInvalidation"], Resource = module.cdn.distribution_arn }
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
