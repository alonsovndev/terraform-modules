data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_iam_role" "this" {
  name_prefix = "${var.name}-run-"
  tags        = var.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "runtime" {
  role = aws_iam_role.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "${aws_cloudwatch_log_group.this.arn}:*"
      }], length(var.secret_arns) > 0 ? [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = var.secret_arns
    }] : [])
  })
}

resource "aws_iam_role_policy" "application" {
  count = var.runtime_policy == null ? 0 : 1

  role   = aws_iam_role.this.id
  policy = var.runtime_policy.policy_json
}

resource "aws_lambda_function" "this" {
  function_name                  = var.name
  role                           = aws_iam_role.this.arn
  package_type                   = "Image"
  image_uri                      = var.image_uri
  architectures                  = [var.architecture]
  memory_size                    = var.memory_size_mb
  timeout                        = var.timeout_seconds
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.tags

  environment {
    variables = merge(var.environment, {
      AWS_LWA_PORT                 = tostring(var.application_port)
      AWS_LWA_READINESS_CHECK_PATH = var.readiness_path
    })
  }

  depends_on = [aws_iam_role_policy.runtime, aws_iam_role_policy.application]

  lifecycle {
    precondition {
      condition     = try(split(".", var.image_uri)[3] == data.aws_region.current.region, false)
      error_message = "The ECR image must be in the Lambda provider region."
    }
  }
}

resource "aws_apigatewayv2_api" "this" {
  name          = var.name
  protocol_type = "HTTP"
  tags          = var.tags
}

resource "aws_apigatewayv2_integration" "this" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.this.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 30000
}

resource "aws_apigatewayv2_route" "this" {
  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "$default"
  target             = "integrations/${aws_apigatewayv2_integration.this.id}"
  authorization_type = "NONE"
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/apigateway/${var.name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
  tags        = var.tags

  default_route_settings {
    throttling_burst_limit = var.throttling.burst_limit
    throttling_rate_limit  = var.throttling.rate_limit
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      status         = "$context.status"
      responseLength = "$context.responseLength"
    })
  }
}

resource "aws_lambda_permission" "api" {
  statement_id  = "AllowHttpApi"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
