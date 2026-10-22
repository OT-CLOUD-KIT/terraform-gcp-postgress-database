variable "project" {
  description = "Google Cloud project ID that hosts the Cloud SQL instance."
  type        = string
}
variable "region" {
  description = "Google Cloud region for the Cloud SQL instance."
  type        = string
}
variable "name" {
  description = "Cloud SQL instance name."
  type        = string
}
variable "engine" {
  description = "PostgreSQL database version, for example POSTGRES_15 or POSTGRES_16."
  type        = string
  validation {
    condition     = startswith(var.engine, "POSTGRES_")
    error_message = "This module supports PostgreSQL versions only; engine must start with POSTGRES_."
  }
}
variable "machine_type" {
  description = "Cloud SQL tier, for example db-custom-2-7680."
  type        = string
}
variable "db_name" {
  description = "Name of the application database to create."
  type        = string
}
variable "master_user_name" {
  description = "Name of the PostgreSQL application user to create."
  type        = string
}
variable "master_user_password" {
  description = "Password for the PostgreSQL application user. Pass it from a secret source; it is stored in Terraform state."
  type        = string
  sensitive   = true
}
variable "edition" {
  description = "Cloud SQL edition: ENTERPRISE or ENTERPRISE_PLUS."
  type        = string
  default     = "ENTERPRISE"
  validation {
    condition     = contains(["ENTERPRISE", "ENTERPRISE_PLUS"], var.edition)
    error_message = "edition must be ENTERPRISE or ENTERPRISE_PLUS."
  }
}
variable "availability_type" {
  description = "ZONAL or REGIONAL. Null preserves compatibility with enable_failover_replica."
  type        = string
  default     = null
  nullable    = true
  validation {
    condition     = var.availability_type == null || contains(["ZONAL", "REGIONAL"], var.availability_type)
    error_message = "availability_type must be ZONAL, REGIONAL, or null."
  }
}
variable "enable_failover_replica" {
  description = "Deprecated compatibility input. For PostgreSQL, true selects REGIONAL HA; prefer availability_type."
  type        = bool
  default     = false
}
variable "activation_policy" {
  description = "Instance activation policy."
  type        = string
  default     = "ALWAYS"
}
variable "authorized_networks" {
  description = "Public CIDR ranges allowed to connect."
  type = list(object({
    name            = optional(string)
    value           = string
    expiration_time = optional(string)
  }))
  default = []
}
variable "backup_enabled" {
  description = "Enable automated backups. Required for PITR and REGIONAL HA."
  type        = bool
  default     = true
}
variable "backup_start_time" {
  description = "Daily backup start time in HH:MM UTC format."
  type        = string
  default     = "04:00"
  validation {
    condition     = can(regex("^(?:[01][0-9]|2[0-3]):[0-5][0-9]$", var.backup_start_time))
    error_message = "backup_start_time must use HH:MM in 24-hour UTC format."
  }
}
variable "backup_location" {
  description = "Optional regional or multi-regional location for backups."
  type        = string
  default     = null
}
variable "retained_backups" {
  description = "Number of automated backups retained."
  type        = number
  default     = 14
  validation {
    condition     = var.retained_backups >= 1 && var.retained_backups <= 365
    error_message = "retained_backups must be between 1 and 365."
  }
}
variable "postgres_point_in_time_recovery_enabled" {
  description = "Enable PostgreSQL point-in-time recovery."
  type        = bool
  default     = true
}
variable "transaction_log_retention_days" {
  description = "Days of PostgreSQL transaction logs retained for PITR."
  type        = number
  default     = 7
  validation {
    condition     = var.transaction_log_retention_days >= 1 && var.transaction_log_retention_days <= 7
    error_message = "transaction_log_retention_days must be between 1 and 7."
  }
}
variable "encryption_key_name" {
  description = "Optional Cloud KMS CryptoKey resource name for CMEK. The key and Cloud SQL instance must use the same region."
  type        = string
  default     = null
}
variable "private_network" {
  description = "VPC network self-link for private IP connectivity. Required when public access is disabled."
  type        = string
  default     = null
}
variable "enable_public_internet_access" {
  description = "Enable a public IPv4 address. Keep false for private production databases."
  type        = bool
  default     = false
}
variable "require_ssl" {
  description = "Deprecated compatibility input. True maps to ssl_mode ENCRYPTED_ONLY; prefer ssl_mode."
  type        = bool
  default     = true
}
variable "ssl_mode" {
  description = "Cloud SQL SSL enforcement mode. Null maps the legacy require_ssl input to the matching provider v7 value."
  type        = string
  default     = null
  nullable    = true
  validation {
    condition = var.ssl_mode == null || contains([
      "ALLOW_UNENCRYPTED_AND_ENCRYPTED",
      "ENCRYPTED_ONLY",
      "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"
    ], var.ssl_mode)
    error_message = "ssl_mode must be ALLOW_UNENCRYPTED_AND_ENCRYPTED, ENCRYPTED_ONLY, TRUSTED_CLIENT_CERTIFICATE_REQUIRED, or null."
  }
}
variable "maintenance_window_day" {
  description = "Maintenance day: 1 (Monday) through 7 (Sunday)."
  type        = number
  default     = 7
}
variable "maintenance_window_hour" {
  description = "Maintenance hour in UTC, from 0 through 23."
  type        = number
  default     = 7
}
variable "maintenance_track" {
  description = "Maintenance update track: canary or stable."
  type        = string
  default     = "stable"
}
variable "db_charset" {
  description = "Optional database character set."
  type        = string
  default     = null
}
variable "db_collation" {
  description = "Optional database collation."
  type        = string
  default     = null
}
variable "database_flags" {
  description = "PostgreSQL database flags."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
variable "disk_autoresize" {
  description = "Allow Cloud SQL to grow storage automatically."
  type        = bool
  default     = true
}
variable "disk_size" {
  description = "Initial data disk size in GiB."
  type        = number
  default     = 20
}
variable "disk_type" {
  description = "Storage type: PD_SSD or PD_HDD."
  type        = string
  default     = "PD_SSD"
}
variable "master_zone" {
  description = "Optional preferred primary zone."
  type        = string
  default     = null
}
variable "master_user_host" {
  description = "Deprecated compatibility input; PostgreSQL users do not use a host field."
  type        = string
  default     = "%"
}
variable "mysql_binary_log_enabled" {
  description = "Deprecated compatibility input; ignored because this module is PostgreSQL-only."
  type        = bool
  default     = true
}
variable "mysql_failover_replica_zone" {
  description = "Deprecated compatibility input; ignored because PostgreSQL REGIONAL HA is managed by Cloud SQL."
  type        = string
  default     = null
}
variable "num_read_replicas" {
  description = "Number of same-region PostgreSQL read replicas."
  type        = number
  default     = 0
  validation {
    condition     = var.num_read_replicas >= 0 && floor(var.num_read_replicas) == var.num_read_replicas
    error_message = "num_read_replicas must be a non-negative integer."
  }
}
variable "read_replica_zones" {
  description = "One zone for each read replica."
  type        = list(string)
  default     = []
}
variable "custom_labels" {
  description = "Labels applied to primary and replica instances."
  type        = map(string)
  default     = {}
}
variable "resource_timeout" {
  description = "Create, update, and delete timeout for Cloud SQL instances."
  type        = string
  default     = "60m"
}
variable "deletion_protection" {
  description = "Prevent Terraform from deleting database instances."
  type        = bool
  default     = true
}
variable "dependencies" {
  description = "Deprecated compatibility input for private service access and KMS IAM dependencies. Prefer module-level depends_on."
  type        = list(string)
  default     = []
}
