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

variable "existing_provider_arn" {
  type        = string
  description = "GitHub OIDC provider ARN to reuse when create_provider is false; may be unknown during planning."
  default     = null
  nullable    = true
  validation {
    condition     = var.create_provider ? var.existing_provider_arn == null : can(regex("^arn:[^:]+:iam::[0-9]{12}:oidc-provider/token\\.actions\\.githubusercontent\\.com$", var.existing_provider_arn))
    error_message = "Omit the ARN when creating the provider; supply a GitHub OIDC provider ARN when create_provider is false."
  }
}

variable "create_provider" {
  description = "Create the account-wide provider, or set false to reuse existing_provider_arn. This selection must be known at plan time."
  type        = bool
  default     = true
  nullable    = false
}

variable "roles" {
  type        = map(object({ subjects = set(string), policy_json = string, max_session_duration = optional(number, 3600) }))
  description = "Roles keyed by name, with exact GitHub branch/tag or environment subjects and caller-owned permission policies."
  nullable    = false
  validation {
    condition     = length(var.roles) > 0 && alltrue([for role_name, role in var.roles : can(regex("^[a-zA-Z0-9+=,.@_-]+$", role_name)) && length("${var.name}-${role_name}") <= 64 && length(role.subjects) > 0 && alltrue([for subject in role.subjects : can(regex("^repo:[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+:(ref:refs/(heads|tags)/[^*?]+|environment:[^*?]+)$", subject))]) && can(jsondecode(role.policy_json).Statement) && role.max_session_duration >= 3600 && role.max_session_duration <= 43200 && floor(role.max_session_duration) == role.max_session_duration])
    error_message = "Supply valid role names, nonempty exact repository/ref or environment subjects, IAM policy JSON, and 3600\u201343200 second sessions. Wildcards and pull-request subjects are unsupported."
  }
}
