variable "project_id" {
  description = "Project that hosts Cloud SQL."
  type        = string
}
variable "region" {
  description = "Cloud SQL and KMS region."
  type        = string
}
variable "instance_name" {
  description = "Cloud SQL instance name."
  type        = string
}
variable "postgres_version" {
  description = "PostgreSQL version."
  type        = string
  default     = "POSTGRES_16"
}
variable "machine_type" {
  description = "Cloud SQL tier."
  type        = string
  default     = "db-custom-2-7680"
}
variable "database_name" {
  description = "Application database name."
  type        = string
}
variable "database_user" {
  description = "Application database user."
  type        = string
}
variable "database_password" {
  description = "Application user password. Supply through a secret source or TF_VAR_database_password."
  type        = string
  sensitive   = true
}
variable "private_network_self_link" {
  description = "Existing VPC self-link with Private Service Access configured."
  type        = string
}
variable "kms_key_name" {
  description = "Optional same-region Cloud KMS CryptoKey resource name for CMEK."
  type        = string
  default     = null
}
