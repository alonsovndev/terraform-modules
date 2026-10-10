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

variable "cidr_block" {
  type        = string
  description = "IPv4 CIDR for the VPC."
  nullable    = false
  validation {
    condition     = can(cidrnetmask(var.cidr_block))
    error_message = "Supply a valid IPv4 VPC CIDR."
  }
}

variable "subnets" {
  type        = map(object({ public_cidr = string, private_cidr = string }))
  description = "Public/private IPv4 CIDRs keyed by availability zone; all must lie inside the VPC and not overlap."
  nullable    = false
  validation {
    condition     = length(var.subnets) >= 2 && alltrue([for availability_zone, subnets in var.subnets : can(regex("^[a-z]{2}(-[a-z]+)+-[0-9][a-z]$", availability_zone)) && can(cidrnetmask(subnets.public_cidr)) && can(cidrnetmask(subnets.private_cidr))]) && length(distinct(flatten([for subnets in values(var.subnets) : [subnets.public_cidr, subnets.private_cidr]]))) == 2 * length(var.subnets)
    error_message = "Supply at least two availability zones with valid, distinct IPv4 subnet CIDRs."
  }
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Create a paid NAT gateway per availability zone. Without NAT, consumers must arrange private-task outbound access."
  default     = false
  nullable    = false
}
