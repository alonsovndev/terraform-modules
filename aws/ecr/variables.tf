variable "name" {
  type        = string
  description = "Private ECR repository name, optionally including namespace segments."
  nullable    = false
  validation {
    condition     = length(var.name) >= 2 && length(var.name) <= 256 && can(regex("^[a-z0-9]+([._/-][a-z0-9]+)*$", var.name))
    error_message = "Supply a valid 2\u2013256 character lowercase ECR repository name."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags attached to taggable AWS resources."
  default     = {}
  nullable    = false
}

variable "untagged_retention_days" {
  type        = number
  description = "Days before expiring untagged images; retain deployment images under immutable tags."
  default     = 30
  nullable    = false
  validation {
    condition     = var.untagged_retention_days >= 1 && floor(var.untagged_retention_days) == var.untagged_retention_days
    error_message = "Retention must be a positive whole number of days."
  }
}
