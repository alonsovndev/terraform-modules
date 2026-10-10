output "function_arn" {
  description = "Lambda function ARN."
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Lambda function name."
  value       = aws_lambda_function.this.function_name
}

output "runtime_role_arn" {
  description = "Application runtime role ARN."
  value       = aws_iam_role.this.arn
}

output "api_endpoint" {
  description = "Public HTTP API endpoint; authentication is the application's responsibility."
  value       = aws_apigatewayv2_api.this.api_endpoint
}
