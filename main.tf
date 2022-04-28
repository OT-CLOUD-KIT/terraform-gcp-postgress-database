resource "google_sql_database_instance" "default" {
  project             = var.project_id
  name                = var.name
  database_version    = var.database_version
  region              = var.region
  #encryption_key_name = var.encryption_key_name
  deletion_protection = var.deletion_protection

  settings {
    tier              = lookup(var.settings, "tier", "db-f1-micro")
    disk_type         = lookup(var.settings, "disk_type", "PD_SSD")
    disk_size         = lookup(var.settings, "disk_size", 10)
    disk_autoresize   = lookup(var.settings, "disk_auto", true)
    activation_policy = lookup(var.settings, "activation_policy", "ALWAYS")
    availability_type = lookup(var.settings, "availability_type", "ZONAL")

    dynamic "backup_configuration" {
      for_each = [var.backup_configuration]
      content {
        binary_log_enabled             = can(regex("POSTGRES", var.database_version)) == true ? false : lookup(backup_configuration.value, "binary_log_enabled", null)
        enabled                        = lookup(backup_configuration.value, "enabled", null)
        start_time                     = lookup(backup_configuration.value, "start_time", null)
        location                       = lookup(backup_configuration.value, "location", null)
        point_in_time_recovery_enabled = can(regex("POSTGRES", var.database_version)) == true ? lookup(backup_configuration.value, "point_in_time_recovery_enabled", false) : false
        transaction_log_retention_days = lookup(backup_configuration.value, "transaction_log_retention_days", null)

        dynamic "backup_retention_settings" {
          for_each = local.retained_backups != null || local.retention_unit != null ? [var.backup_configuration] : []
          content {
            retained_backups = local.retained_backups
            retention_unit   = local.retention_unit
          }
        }
      }
    }
    dynamic "ip_configuration" {
      for_each = [var.ip_configuration]
      content {
        ipv4_enabled       = lookup(ip_configuration.value, "ipv4_enabled", null)
        private_network    = lookup(ip_configuration.value, "private_network", null)
        require_ssl        = lookup(ip_configuration.value, "require_ssl", null)
        allocated_ip_range = lookup(ip_configuration.value, "allocated_ip_range", null)

        dynamic "authorized_networks" {
          for_each = lookup(ip_configuration.value, "authorized_networks", [])
          content {
            expiration_time = lookup(authorized_networks.value, "expiration_time", null)
            name            = lookup(authorized_networks.value, "name", null)
            value           = lookup(authorized_networks.value, "value", null)
          }
        }
      }
    }
    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = lookup(database_flags.value, "name", null)
        value = lookup(database_flags.value, "value", null)
      }
    }
    dynamic "insights_config" {
      for_each = var.insights_config != null ? [var.insights_config] : []
      content {
        query_insights_enabled  = true
        query_string_length     = lookup(insights_config.value, "query_string_length", 1024)
        record_application_tags = lookup(insights_config.value, "record_application_tags", false)
        record_client_address   = lookup(insights_config.value, "record_client_address", false)
      }
    }
    maintenance_window {
      day          = var.maintenance_window_day
      hour         = var.maintenance_window_hour
      update_track = var.maintenance_window_update_track
    }
    user_labels = merge(
      {
        managedby = "terraform"
      },
      var.user_labels
    )
  }
  timeouts {
    create = var.create_timeout
    update = var.update_timeout
    delete = var.delete_timeout
  }
}

resource "google_sql_database" "default" {
  for_each   = local.databases
  name       = each.value.name
  charset    = lookup(each.value, "charset", null)
  collation  = lookup(each.value, "collation", null)
  instance   = google_sql_database_instance.default.name
  depends_on = [google_sql_database_instance.default]
}

resource "google_sql_user" "default" {
  for_each = local.users
  name     = each.value.name
  instance = google_sql_database_instance.default.name
  password = lookup(each.value,"password", random_password.password[each.value.name].result)
  depends_on = [
    google_sql_database_instance.default
  ]
}

resource "random_password" "password" {
  for_each = local.users
  length   = 16
  special  = false
}