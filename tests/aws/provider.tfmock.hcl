mock_data "aws_region" {
  override_during = plan
  defaults        = { region = "us-east-1" }
}

mock_data "aws_caller_identity" {
  override_during = plan
  defaults        = { account_id = "123456789012", arn = "arn:aws:iam::123456789012:root" }
}

mock_resource "aws_iam_role" {
  override_during = plan
  defaults        = { arn = "arn:aws:iam::123456789012:role/example-role" }
}

mock_resource "aws_security_group" {
  override_during = plan
  defaults        = { id = "sg-00000000000000001" }
}

mock_resource "aws_subnet" {
  override_during = plan
}

mock_resource "aws_nat_gateway" {
  override_during = plan
}

mock_resource "aws_iam_openid_connect_provider" {
  override_during = plan
  defaults        = { arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com" }
}

mock_resource "aws_cloudwatch_log_group" {
  override_during = plan
  defaults        = { arn = "arn:aws:logs:us-east-1:123456789012:log-group:example" }
}

mock_resource "aws_s3_bucket" {
  override_during = plan
  defaults = {
    arn                         = "arn:aws:s3:::example-static"
    bucket_regional_domain_name = "example-static.s3.us-east-1.amazonaws.com"
  }
}

mock_resource "aws_cloudfront_distribution" {
  override_during = plan
  defaults = {
    arn            = "arn:aws:cloudfront::123456789012:distribution/EXAMPLE"
    domain_name    = "example.cloudfront.net"
    hosted_zone_id = "Z2FDTNDATAQYW2"
  }
}

mock_resource "aws_cloudfront_origin_access_control" {
  override_during = plan
  defaults        = { id = "example-oac" }
}

mock_resource "aws_ecr_repository" {
  override_during = plan
  defaults = {
    arn            = "arn:aws:ecr:us-east-1:123456789012:repository/example-api"
    repository_url = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example-api"
  }
}

mock_resource "aws_ecs_cluster" {
  override_during = plan
  defaults        = { arn = "arn:aws:ecs:us-east-1:123456789012:cluster/example-api" }
}

mock_resource "aws_ecs_task_definition" {
  override_during = plan
  defaults        = { arn = "arn:aws:ecs:us-east-1:123456789012:task-definition/example-api:1" }
}

mock_resource "aws_lb" {
  override_during = plan
  defaults        = { arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/example/0000000000000000" }
}

mock_resource "aws_lb_target_group" {
  override_during = plan
  defaults        = { arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/example/0000000000000000" }
}

mock_resource "aws_lambda_function" {
  override_during = plan
  defaults = {
    arn        = "arn:aws:lambda:us-east-1:123456789012:function:example-api"
    invoke_arn = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:example-api/invocations"
  }
}

mock_resource "aws_apigatewayv2_api" {
  override_during = plan
  defaults = {
    execution_arn = "arn:aws:execute-api:us-east-1:123456789012:example"
    api_endpoint  = "https://example.execute-api.us-east-1.amazonaws.com"
  }
}

mock_resource "aws_db_instance" {
  override_during = plan
  defaults = {
    endpoint = "example.database.invalid:5432"
    master_user_secret = [{
      secret_arn    = "arn:aws:secretsmanager:us-east-1:123456789012:secret:example-000000"
      kms_key_id    = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000"
      secret_status = "active"
    }]
  }
}
