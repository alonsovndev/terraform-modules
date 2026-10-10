provider "aws" {
  region = "us-east-1"
}

variable "image_uri" {
  description = "Prebuilt image digest in the example-api repository; build and push separately."
  type        = string
}

variable "acm_certificate_arn" {
  description = "Validated us-east-1 ACM certificate covering your application hostname."
  type        = string
}

variable "postgres_version" {
  description = "Supported PostgreSQL engine version available in us-east-1."
  type        = string
}

module "network" {
  source             = "../../aws/vpc"
  name               = "example-network"
  cidr_block         = "10.20.0.0/16"
  enable_nat_gateway = true
  subnets = {
    us-east-1a = { public_cidr = "10.20.0.0/24", private_cidr = "10.20.10.0/24" }
    us-east-1b = { public_cidr = "10.20.1.0/24", private_cidr = "10.20.11.0/24" }
  }
}

module "repository" {
  source = "../../aws/ecr"
  name   = "example-api"
}

module "service" {
  source               = "../../aws/ecs-service"
  name                 = "example-api"
  vpc_id               = module.network.vpc_id
  public_subnet_ids    = values(module.network.public_subnet_ids)
  private_subnet_ids   = values(module.network.private_subnet_ids)
  image_uri            = var.image_uri
  image_repository_arn = module.repository.repository_arn
  acm_certificate_arn  = var.acm_certificate_arn
  environment          = { APP_ENV = "prod" }
}

module "database" {
  source                    = "../../aws/rds-postgres"
  name                      = "example-postgres"
  vpc_id                    = module.network.vpc_id
  private_subnet_ids        = values(module.network.private_subnet_ids)
  client_security_group_ids = { api = module.service.task_security_group_id }
  engine_version            = var.postgres_version
  database_name             = "application"
  final_snapshot_identifier = "example-postgres-final-replace-before-teardown"
}

resource "aws_vpc_security_group_egress_rule" "database" {
  security_group_id            = module.service.task_security_group_id
  referenced_security_group_id = module.database.security_group_id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

output "load_balancer_hostname" {
  description = "Point a certificate-matching hostname at this ALB before accessing HTTPS."
  value       = module.service.load_balancer_dns_name
}

output "database_endpoint" {
  description = "Private PostgreSQL endpoint; application configuration and user provisioning are separate."
  value       = module.database.endpoint
}
