variable "name" {
  type        = string
  description = "Resource name prefix; use lowercase letters, digits, and hyphens."
  nullable    = false
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.name))
    error_message = "Use a 3\u201332 character lowercase name beginning with a letter and ending with a letter or digit."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags attached to taggable AWS resources."
  default     = {}
  nullable    = false
}

variable "image_uri" {
  type        = string
  description = "Prebuilt private ECR image URI pinned to a SHA-256 digest."
  nullable    = false
  validation {
    condition     = can(regex("^[0-9]{12}\\.dkr\\.ecr\\.[a-z0-9-]+\\.amazonaws\\.com(\\.cn)?/[a-z0-9._/-]+@sha256:[a-f0-9]{64}$", var.image_uri))
    error_message = "Supply a private ECR image URI with a lowercase SHA-256 digest, not a mutable tag."
  }
}

variable "architecture" {
  type        = string
  description = "Single image architecture."
  default     = "x86_64"
  nullable    = false
  validation {
    condition     = contains(["x86_64", "arm64"], var.architecture)
    error_message = "Choose x86_64 or arm64."
  }
}

variable "application_port" {
  type        = number
  description = "HTTP application port used by Lambda Web Adapter."
  default     = 8080
  nullable    = false
  validation {
    condition     = var.application_port >= 1 && var.application_port <= 65535 && floor(var.application_port) == var.application_port
    error_message = "Use a whole-number TCP port between 1 and 65535."
  }
}

variable "readiness_path" {
  type        = string
  description = "Lambda Web Adapter readiness endpoint."
  default     = "/health/ready"
  nullable    = false
  validation {
    condition     = startswith(var.readiness_path, "/")
    error_message = "Use an absolute readiness request path."
  }
}

variable "memory_size_mb" {
  type        = number
  description = "Lambda memory in MiB."
  default     = 512
  nullable    = false
  validation {
    condition     = var.memory_size_mb >= 128 && var.memory_size_mb <= 10240 && floor(var.memory_size_mb) == var.memory_size_mb
    error_message = "Use a whole number between 128 and 10240 MiB."
  }
}

variable "timeout_seconds" {
  type        = number
  description = "Function timeout in seconds, limited to the HTTP API integration timeout."
  default     = 28
  nullable    = false
  validation {
    condition     = var.timeout_seconds >= 1 && var.timeout_seconds <= 30 && floor(var.timeout_seconds) == var.timeout_seconds
    error_message = "Choose a whole-number timeout between 1 and 30 seconds."
  }
}

variable "reserved_concurrency" {
  type        = number
  description = "Reserved Lambda concurrency; null leaves account-managed concurrency. Check account limits before reserving."
  default     = null
  nullable    = true
  validation {
    condition     = var.reserved_concurrency == null ? true : var.reserved_concurrency >= 1 && floor(var.reserved_concurrency) == var.reserved_concurrency
    error_message = "Use null or a positive whole-number concurrency reservation."
  }
}

variable "throttling" {
  type        = object({ burst_limit = number, rate_limit = number })
  description = "HTTP API burst request limit and sustained requests per second."
  default     = { burst_limit = 10, rate_limit = 5 }
  nullable    = false
  validation {
    condition     = var.throttling.burst_limit >= 1 && floor(var.throttling.burst_limit) == var.throttling.burst_limit && var.throttling.rate_limit > 0
    error_message = "Use a positive whole-number burst limit and positive requests-per-second rate."
  }
}

variable "environment" {
  type        = map(string)
  description = "Nonsecret application environment variables; never pass credentials here."
  default     = {}
  nullable    = false

  validation {
    condition = alltrue([for environment_name in keys(var.environment) : can(regex("^[A-Za-z][A-Za-z0-9_]+$", environment_name))]) && length(setintersection(toset(keys(var.environment)), toset([
      "AWS_LWA_PORT", "AWS_LWA_READINESS_CHECK_PATH", "AWS_REGION", "AWS_DEFAULT_REGION", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN", "AWS_LAMBDA_FUNCTION_NAME", "AWS_LAMBDA_FUNCTION_VERSION", "AWS_LAMBDA_FUNCTION_MEMORY_SIZE", "AWS_LAMBDA_LOG_GROUP_NAME", "AWS_LAMBDA_LOG_STREAM_NAME", "AWS_EXECUTION_ENV", "AWS_LAMBDA_RUNTIME_API", "_HANDLER", "_X_AMZN_TRACE_ID", "LAMBDA_TASK_ROOT", "LAMBDA_RUNTIME_DIR"
    ]))) == 0
    error_message = "Use valid Lambda environment names and do not override reserved runtime or module-managed adapter settings."
  }
}

variable "secret_arns" {
  type        = set(string)
  description = "Secret ARNs the application may retrieve at runtime; values never enter Terraform."
  default     = []
  nullable    = false
  validation {
    condition     = alltrue([for secret_arn in var.secret_arns : can(regex("^arn:[^:]+:secretsmanager:[a-z0-9-]+:[0-9]{12}:secret:[^:]+$", secret_arn))])
    error_message = "Supply complete Secrets Manager secret ARNs."
  }
}

variable "runtime_policy" {
  type        = object({ policy_json = string })
  description = "Optional scoped runtime policy object; its presence must be known at plan time, but policy_json may include new resource ARNs."
  default     = null
  nullable    = true
  validation {
    condition     = var.runtime_policy == null ? true : can(jsondecode(var.runtime_policy.policy_json).Statement)
    error_message = "Supply a policy object with IAM policy_json containing Statement, or null."
  }
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention in days."
  default     = 30
  nullable    = false
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_retention_days)
    error_message = "Choose a supported CloudWatch log retention period."
  }
}
