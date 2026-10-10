variable "name" {
  type        = string
  description = "Resource name prefix; use lowercase letters, digits, and hyphens."
  nullable    = false
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.name)) && !strcontains(var.name, "--")
    error_message = "Use a 3\u201332 character lowercase name beginning with a letter and ending with a letter or digit."
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
  description = "VPC containing the private database subnets."
  nullable    = false
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

variable "client_security_group_ids" {
  type        = map(string)
  description = "Allowed client security group IDs keyed by stable caller-chosen names."
  default     = {}
  nullable    = false
}

variable "engine_version" {
  type        = string
  description = "PostgreSQL engine version available in the selected region."
  nullable    = false
  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]+){1,2}$", var.engine_version))
    error_message = "Supply an explicit PostgreSQL version, such as 17.7; regional availability is checked during deployment."
  }
}

variable "instance_class" {
  type        = string
  description = "RDS PostgreSQL instance class available in the selected region."
  default     = "db.t4g.micro"
  nullable    = false
  validation {
    condition     = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", var.instance_class))
    error_message = "Supply a valid RDS instance class name."
  }
}

variable "allocated_storage_gib" {
  type        = number
  description = "Allocated gp3 storage in GiB."
  default     = 20
  nullable    = false
  validation {
    condition     = var.allocated_storage_gib >= 20 && var.allocated_storage_gib <= 65536 && floor(var.allocated_storage_gib) == var.allocated_storage_gib
    error_message = "Allocate a whole number of GiB between 20 and 65536."
  }
}

variable "database_name" {
  type        = string
  description = "Initial database name."
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]{0,62}$", var.database_name))
    error_message = "Use 1\u201363 alphanumeric characters, beginning with a letter."
  }
}

variable "master_username" {
  type        = string
  description = "Initial PostgreSQL master username; applications should use separate least-privilege users."
  default     = "appadmin"
  nullable    = false
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,62}$", var.master_username)) && !contains(["admin", "postgres", "rdsadmin"], lower(var.master_username))
    error_message = "Supply a nonreserved PostgreSQL master username."
  }
}

variable "multi_az" {
  type        = bool
  description = "Enable the paid Multi-AZ standby."
  default     = false
  nullable    = false
}

variable "backup_retention_days" {
  type        = number
  description = "Automatic backup retention in days; backups cannot be disabled."
  default     = 7
  nullable    = false
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35 && floor(var.backup_retention_days) == var.backup_retention_days
    error_message = "Backup retention must be a whole number between 1 and 35 days."
  }
}

variable "deletion_protection" {
  type        = bool
  description = "Protect the instance against deletion; disable only for an explicitly approved teardown."
  default     = true
  nullable    = false
}

variable "final_snapshot_identifier" {
  type        = string
  description = "Unique final snapshot name for a future approved teardown; select a new name if a snapshot already exists."
  nullable    = false
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,253}[a-z0-9]$", var.final_snapshot_identifier)) && !strcontains(var.final_snapshot_identifier, "--")
    error_message = "Supply a valid, unique RDS final snapshot identifier."
  }
}
