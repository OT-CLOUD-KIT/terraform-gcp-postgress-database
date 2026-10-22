# Terraform GCP PostgreSQL Database

This Terraform module provisions a production-ready Cloud SQL for PostgreSQL environment on Google Cloud. It creates the primary database instance, application database, database user and optional read replicas.

The module supports private IP connectivity, regional high availability, automated backups, point-in-time recovery, encrypted connections, customer-managed encryption keys and deletion protection.

## Architecture

The module manages the following components:

- Cloud SQL for PostgreSQL primary instance
- Application PostgreSQL database and user
- Optional same-region read replicas
- Private or public IP configuration
- Regional high availability
- Automated backups and point-in-time recovery
- Optional Cloud KMS encryption
- Maintenance window, database flags and resource labels

Private Service Access, the VPC network and the Cloud KMS key are expected to be managed outside this module.

## Providers

| Name | Source | Version |
|---|---|---|
| Google | `hashicorp/google` | `~> 7.0` |

## Requirements

| Name | Version |
|---|---|
| Terraform | `>= 1.7, < 2.0` |

## Resources

| Resource | Purpose |
|---|---|
| `google_sql_database_instance.master` | Primary PostgreSQL instance |
| `google_sql_database.default` | Application database |
| `google_sql_user.default` | Application database user |
| `google_sql_database_instance.read_replica` | Optional read replicas |
| `terraform_data.dependency_getter` | Carries external networking or KMS dependencies |

## Usage

```hcl
module "postgres" {
  source = "./terraform-gcp-postgress-database"

  project              = "example-project"
  region               = "us-central1"
  name                 = "payments-prod-postgres"
  engine               = "POSTGRES_16"
  machine_type         = "db-custom-2-7680"
  db_name              = "payments"
  master_user_name     = "payments_app"
  master_user_password = var.database_password

  availability_type                       = "REGIONAL"
  backup_enabled                          = true
  postgres_point_in_time_recovery_enabled = true
  retained_backups                        = 14
  transaction_log_retention_days          = 7

  enable_public_internet_access = false
  private_network               = "projects/example-project/global/networks/shared-vpc"
  ssl_mode                      = "ENCRYPTED_ONLY"
  encryption_key_name           = var.kms_key_name
  deletion_protection           = true

  custom_labels = {
    environment = "prod"
    managed_by  = "terraform"
  }
}
```

A complete private IP example is available under `example/postgres-private-ip`.

## Inputs

### Required inputs

| Name | Description | Type |
|---|---|---|
| `project` | Google Cloud project hosting Cloud SQL | `string` |
| `region` | Cloud SQL region | `string` |
| `name` | Primary instance name | `string` |
| `engine` | PostgreSQL version such as `POSTGRES_16` | `string` |
| `machine_type` | Cloud SQL machine tier | `string` |
| `db_name` | Application database name | `string` |
| `master_user_name` | Application database user | `string` |
| `master_user_password` | Application user password | `string`, sensitive |

### Optional inputs

| Name | Description | Default |
|---|---|---|
| `edition` | Cloud SQL edition | `ENTERPRISE` |
| `availability_type` | `ZONAL` or `REGIONAL` | `null` |
| `enable_failover_replica` | Legacy input mapping to regional HA | `false` |
| `activation_policy` | Instance activation policy | `ALWAYS` |
| `authorized_networks` | Public CIDR allow list | `[]` |
| `backup_enabled` | Enable automated backups | `true` |
| `backup_start_time` | Daily backup time in UTC | `04:00` |
| `backup_location` | Backup location | `null` |
| `retained_backups` | Number of backups retained | `14` |
| `postgres_point_in_time_recovery_enabled` | Enable PITR | `true` |
| `transaction_log_retention_days` | Transaction-log retention | `7` |
| `encryption_key_name` | Cloud KMS CryptoKey resource name | `null` |
| `private_network` | VPC network self-link | `null` |
| `enable_public_internet_access` | Enable public IPv4 | `false` |
| `ssl_mode` | Cloud SQL SSL mode | derived from `require_ssl` |
| `maintenance_window_day` | Maintenance weekday | `7` |
| `maintenance_window_hour` | Maintenance hour in UTC | `7` |
| `maintenance_track` | Maintenance track | `stable` |
| `db_charset` | Database character set | `null` |
| `db_collation` | Database collation | `null` |
| `database_flags` | PostgreSQL database flags | `[]` |
| `disk_autoresize` | Enable automatic storage growth | `true` |
| `disk_size` | Initial storage in GiB | `20` |
| `disk_type` | `PD_SSD` or `PD_HDD` | `PD_SSD` |
| `master_zone` | Preferred primary zone | `null` |
| `num_read_replicas` | Number of read replicas | `0` |
| `read_replica_zones` | Zone for each read replica | `[]` |
| `custom_labels` | Resource labels | `{}` |
| `resource_timeout` | Create, update and delete timeout | `60m` |
| `deletion_protection` | Protect instances from deletion | `true` |
| `dependencies` | External dependency values | `[]` |

## Outputs

| Name | Description |
|---|---|
| `master_instance_name` | Primary Cloud SQL instance name |
| `master_private_ip_address` | Primary private IPv4 address |
| `master_public_ip_address` | Primary public IPv4 address, when enabled |
| `master_ip_addresses` | All primary instance IP objects |
| `master_instance` | Primary instance self-link |
| `master_connection_name` | Cloud SQL connector/Auth Proxy connection name |
| `db` | Application database self-link |
| `db_name` | Application database name |
| `read_replica_names` | Read replica names |
| `service_account_email_address` | Cloud SQL service identity used for CMEK access |

## Important considerations

- Configure Private Service Access before using a private network.
- Grant the Cloud SQL service identity access to the selected KMS key before enabling CMEK.
- Store Terraform state in a protected remote backend because the database password is present in state.
- Review changes to high availability, networking and encryption carefully before applying them to an existing database.
