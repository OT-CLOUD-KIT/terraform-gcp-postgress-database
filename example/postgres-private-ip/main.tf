terraform {
  required_version = ">= 1.7, < 2.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "postgres" {
  source = "../../"

  project              = var.project_id
  region               = var.region
  name                 = var.instance_name
  engine               = var.postgres_version
  machine_type         = var.machine_type
  db_name              = var.database_name
  master_user_name     = var.database_user
  master_user_password = var.database_password

  availability_type                       = "REGIONAL"
  backup_enabled                          = true
  postgres_point_in_time_recovery_enabled = true
  retained_backups                        = 14
  transaction_log_retention_days          = 7

  enable_public_internet_access = false
  private_network               = var.private_network_self_link
  ssl_mode                      = "ENCRYPTED_ONLY"
  encryption_key_name           = var.kms_key_name
  deletion_protection           = true

  custom_labels = {
    environment = "prod"
    managed_by  = "terraform"
  }
}
