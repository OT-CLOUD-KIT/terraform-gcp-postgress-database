locals {
  availability_type = coalesce(
    var.availability_type,
    var.enable_failover_replica ? "REGIONAL" : "ZONAL"
  )
  ssl_mode = coalesce(
    var.ssl_mode,
    var.require_ssl ? "ENCRYPTED_ONLY" : "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
  )
}

resource "terraform_data" "dependency_getter" {
  input = var.dependencies
}

resource "google_sql_database_instance" "master" {
  depends_on = [terraform_data.dependency_getter]

  name                = var.name
  project             = var.project
  region              = var.region
  database_version    = var.engine
  encryption_key_name = var.encryption_key_name
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.machine_type
    edition           = var.edition
    activation_policy = var.activation_policy
    availability_type = local.availability_type
    disk_autoresize   = var.disk_autoresize
    disk_size         = var.disk_size
    disk_type         = var.disk_type
    user_labels       = var.custom_labels

    ip_configuration {
      ipv4_enabled    = var.enable_public_internet_access
      private_network = var.private_network
      ssl_mode        = local.ssl_mode

      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name            = authorized_networks.value.name
          value           = authorized_networks.value.value
          expiration_time = authorized_networks.value.expiration_time
        }
      }
    }

    dynamic "location_preference" {
      for_each = var.master_zone == null ? [] : [var.master_zone]
      content {
        zone = location_preference.value
      }
    }

    backup_configuration {
      enabled                        = var.backup_enabled
      start_time                     = var.backup_start_time
      location                       = var.backup_location
      point_in_time_recovery_enabled = var.postgres_point_in_time_recovery_enabled
      transaction_log_retention_days = var.transaction_log_retention_days

      backup_retention_settings {
        retained_backups = var.retained_backups
        retention_unit   = "COUNT"
      }
    }

    maintenance_window {
      day          = var.maintenance_window_day
      hour         = var.maintenance_window_hour
      update_track = var.maintenance_track
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }
  }

  lifecycle {
    precondition {
      condition     = var.backup_enabled || !var.postgres_point_in_time_recovery_enabled
      error_message = "PITR requires backup_enabled = true."
    }
    precondition {
      condition     = local.availability_type != "REGIONAL" || (var.backup_enabled && var.postgres_point_in_time_recovery_enabled)
      error_message = "REGIONAL production HA requires backups and PostgreSQL PITR to be enabled."
    }
    precondition {
      condition     = var.enable_public_internet_access || var.private_network != null
      error_message = "Set private_network when public internet access is disabled."
    }
    precondition {
      condition     = var.enable_public_internet_access || length(var.authorized_networks) == 0
      error_message = "authorized_networks can be used only when public internet access is enabled."
    }
    precondition {
      condition     = var.num_read_replicas == length(var.read_replica_zones)
      error_message = "read_replica_zones must contain exactly one zone for every read replica."
    }
  }

  timeouts {
    create = var.resource_timeout
    delete = var.resource_timeout
    update = var.resource_timeout
  }
}

resource "google_sql_database" "default" {
  name      = var.db_name
  project   = var.project
  instance  = google_sql_database_instance.master.name
  charset   = var.db_charset
  collation = var.db_collation
}

resource "google_sql_user" "default" {
  project  = var.project
  name     = var.master_user_name
  instance = google_sql_database_instance.master.name
  password = var.master_user_password
}

resource "google_sql_database_instance" "read_replica" {
  count = var.num_read_replicas

  depends_on = [google_sql_database.default, google_sql_user.default]

  name                 = "${var.name}-read-${count.index}"
  project              = var.project
  region               = var.region
  database_version     = var.engine
  master_instance_name = google_sql_database_instance.master.name
  encryption_key_name  = var.encryption_key_name
  deletion_protection  = var.deletion_protection

  settings {
    tier              = var.machine_type
    edition           = var.edition
    activation_policy = var.activation_policy
    availability_type = "ZONAL"
    disk_autoresize   = var.disk_autoresize
    disk_size         = var.disk_size
    disk_type         = var.disk_type
    user_labels       = var.custom_labels

    ip_configuration {
      ipv4_enabled    = var.enable_public_internet_access
      private_network = var.private_network
      ssl_mode        = local.ssl_mode
    }

    location_preference {
      zone = var.read_replica_zones[count.index]
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }
  }

  timeouts {
    create = var.resource_timeout
    delete = var.resource_timeout
    update = var.resource_timeout
  }
}
