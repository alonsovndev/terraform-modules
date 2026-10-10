variable "name" {
  type        = string
  description = "Resource name prefix; use lowercase letters, digits, and hyphens."
  nullable    = false
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.name)) && !startswith(var.name, "internal-")
    error_message = "Use a valid 3\u201332 character ALB name without the internal- prefix."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags attached to taggable AWS resources."
  default     = {}
  nullable    = false
}

variable "vpc_id" {
  type        = string
  description = "VPC containing the ALB and Fargate subnets."
  nullable    = false
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public ALB subnet IDs in at least two availability zones."
  nullable    = false
  validation {
    condition     = length(var.public_subnet_ids) >= 2 && length(distinct(var.public_subnet_ids)) == length(var.public_subnet_ids)
    error_message = "Supply at least two distinct public subnet IDs."
  }
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs in at least two availability zones."
  nullable    = false
  validation {
    condition     = length(var.private_subnet_ids) >= 2 && length(distinct(var.private_subnet_ids)) == length(var.private_subnet_ids)
    error_message = "Supply at least two distinct private subnet IDs."
  }
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

variable "image_repository_arn" {
  type        = string
  description = "ECR repository ARN allowed in the execution role pull policy."
  nullable    = false
  validation {
    condition     = can(regex("^arn:[^:]+:ecr:[a-z0-9-]+:[0-9]{12}:repository/[a-z0-9._/-]+$", var.image_repository_arn))
    error_message = "Supply the ARN of the private ECR repository containing the image."
  }
}

variable "acm_certificate_arn" {
  type        = string
  description = "Validated ACM certificate in the ALB provider region."
  nullable    = false
  validation {
    condition     = can(regex("^arn:[^:]+:acm:[a-z0-9-]+:[0-9]{12}:certificate/[a-f0-9-]+$", var.acm_certificate_arn))
    error_message = "Supply a validated ACM certificate ARN."
  }
}

variable "container_port" {
  type        = number
  description = "Application listening port."
  default     = 8080
  nullable    = false
  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535 && floor(var.container_port) == var.container_port
    error_message = "The container port must be a whole number between 1 and 65535."
  }
}

variable "health_check_path" {
  type        = string
  description = "ALB readiness endpoint returning HTTP 200."
  default     = "/health/ready"
  nullable    = false
  validation {
    condition     = startswith(var.health_check_path, "/")
    error_message = "Use an absolute readiness request path."
  }
}

variable "task_size" {
  type        = object({ cpu = number, memory = number })
  description = "Fargate CPU units and memory in MiB; supports 0.25\u20134 vCPU configurations."
  default     = { cpu = 256, memory = 512 }
  nullable    = false
  validation {
    condition     = contains(lookup({ "256" = [512, 1024, 2048], "512" = [1024, 2048, 3072, 4096], "1024" = range(2048, 8193, 1024), "2048" = range(4096, 16385, 1024), "4096" = range(8192, 30721, 1024) }, tostring(var.task_size.cpu), []), var.task_size.memory)
    error_message = "Select a supported Fargate CPU/memory pair."
  }
}

variable "cpu_architecture" {
  type        = string
  description = "Architecture matching the prebuilt image."
  default     = "X86_64"
  nullable    = false
  validation {
    condition     = contains(["X86_64", "ARM64"], var.cpu_architecture)
    error_message = "Choose X86_64 or ARM64."
  }
}

variable "desired_count" {
  type        = number
  description = "Number of Fargate tasks."
  default     = 1
  nullable    = false
  validation {
    condition     = var.desired_count >= 1 && floor(var.desired_count) == var.desired_count
    error_message = "Run at least one task, using a whole number."
  }
}

variable "allowed_ingress_cidrs" {
  type        = set(string)
  description = "IPv4 CIDRs allowed to reach the ALB HTTP redirect and HTTPS listener."
  default     = ["0.0.0.0/0"]
  nullable    = false
  validation {
    condition     = length(var.allowed_ingress_cidrs) > 0 && alltrue([for cidr in var.allowed_ingress_cidrs : can(cidrnetmask(cidr))])
    error_message = "Supply at least one valid IPv4 ingress CIDR."
  }
}

variable "environment" {
  type        = map(string)
  description = "Nonsecret application environment variables; never pass credentials here."
  default     = {}
  nullable    = false
}

variable "secret_arns" {
  type        = map(string)
  description = "Container environment names mapped to Secrets Manager secret ARNs; no secret values or JSON-key suffixes."
  default     = {}
  nullable    = false
  validation {
    condition     = alltrue([for secret_arn in values(var.secret_arns) : can(regex("^arn:[^:]+:secretsmanager:[a-z0-9-]+:[0-9]{12}:secret:[^:]+$", secret_arn))]) && length(setintersection(toset(keys(var.environment)), toset(keys(var.secret_arns)))) == 0
    error_message = "Supply complete Secrets Manager ARNs and do not repeat environment names in environment and secret_arns."
  }
}

variable "task_policy" {
  type        = object({ policy_json = string })
  description = "Optional scoped task policy object; its presence must be known at plan time, but policy_json may include new resource ARNs."
  default     = null
  nullable    = true
  validation {
    condition     = var.task_policy == null ? true : can(jsondecode(var.task_policy.policy_json).Statement)
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
