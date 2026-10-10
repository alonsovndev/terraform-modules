variable "name" {
  type        = string
  description = "Globally unique S3 bucket name; dots are excluded for TLS compatibility."
  nullable    = false
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.name)) && !startswith(var.name, "xn--") && !startswith(var.name, "sthree-") && !startswith(var.name, "amzn-s3-demo-") && !endswith(var.name, "-s3alias") && !endswith(var.name, "--ol-s3") && !endswith(var.name, "--x-s3") && !endswith(var.name, "--table-s3")
    error_message = "Supply a valid, globally unique 3\u201363 character S3 bucket name without dots or reserved prefixes/suffixes."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags attached to taggable AWS resources."
  default     = {}
  nullable    = false
}
