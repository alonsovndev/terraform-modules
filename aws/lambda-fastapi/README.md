# Lambda FastAPI

Create an image-based Lambda with Lambda Web Adapter settings and a throttled API Gateway HTTP API.

## Usage

Example from a root two directories below the repository root. Configure the provider and backend in that consuming root; published consumers should pin the repository source to a reviewed commit or release.

```hcl
module "lambda_fastapi" {
  source = "../../aws/lambda-fastapi"
  name = "example-api"
  image_uri = var.lambda_image_uri
}
```

## Inputs

| Name | Type | Default | Meaning |
|---|---|---|---|
| `name` | `string` | Required | Resource name prefix; use lowercase letters, digits, and hyphens. |
| `tags` | `map(string)` | `{}` | Tags attached to taggable AWS resources. |
| `image_uri` | `string` | Required | Prebuilt private ECR image URI pinned to a SHA-256 digest. |
| `architecture` | `string` | `"x86_64"` | Single image architecture. |
| `application_port` | `number` | `8080` | HTTP application port used by Lambda Web Adapter. |
| `readiness_path` | `string` | `"/health/ready"` | Lambda Web Adapter readiness endpoint. |
| `memory_size_mb` | `number` | `512` | Lambda memory in MiB. |
| `timeout_seconds` | `number` | `28` | Function timeout in seconds, limited to the HTTP API integration timeout. |
| `reserved_concurrency` | `number` | `null` | Reserved Lambda concurrency; null leaves account-managed concurrency. Check account limits before reserving. |
| `throttling` | `object({ burst_limit = number, rate_limit = number })` | `{ burst_limit = 10, rate_limit = 5 }` | HTTP API burst request limit and sustained requests per second. |
| `environment` | `map(string)` | `{}` | Nonsecret application environment variables; never pass credentials here. |
| `secret_arns` | `set(string)` | `[]` | Secret ARNs the application may retrieve at runtime; values never enter Terraform. |
| `runtime_policy` | `object({ policy_json = string })` | `null` | Optional scoped runtime policy object; its presence must be known at plan time, but policy_json may include new resource ARNs. |
| `log_retention_days` | `number` | `30` | CloudWatch log retention in days. |

## Outputs

| Name | Meaning |
|---|---|
| `function_arn` | Lambda function ARN. |
| `function_name` | Lambda function name. |
| `runtime_role_arn` | Application runtime role ARN. |
| `api_endpoint` | Public HTTP API endpoint; authentication is the application's responsibility. |

## Operational constraints

Supply a prebuilt private ECR image in the Lambda provider region, pinned by digest, with one matching architecture. The image must include Lambda Web Adapter under /opt/extensions, start an HTTP server on application_port, provide readiness_path, and tolerate Lambda’s read-only filesystem with writes limited to /tmp. A normal ECS Docker image is not automatically Lambda-compatible. Repository pull permissions and artifact publishing belong to the consuming root. The HTTP API is public; authentication and authorization remain application responsibilities. No Lambda Function URL is created. environment contains nonsecret configuration only. secret_arns grants runtime GetSecretValue permissions; the application retrieves secrets itself. Customer-managed KMS access requires a narrowly scoped runtime_policy.policy_json. HTTP timeouts are capped at 30 seconds. Throttles limit request rates, not monthly cost.

## Verification

Run the repository checks in [development](../../docs/development.md). Tests use plan-only provider mocks; they do not establish deployment or runtime correctness. See [deployment prerequisites](../../docs/deployment.md).
