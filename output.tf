# ------------------------------------------------------------------------------
# MASTER INSTANCE OUTPUTS
# ------------------------------------------------------------------------------

output "master_instance_name" {
  description = "The name of the master database instance"
  value       = google_sql_database_instance.master.name
}


output "master_private_ip_address" {
  description = "The public IPv4 address of the master instance."
  value       = google_sql_database_instance.master.private_ip_address
}

output "master_ip_addresses" {
  description = "All IP addresses of the master instance JSON encoded, see https://www.terraform.io/docs/providers/google/r/sql_database_instance.html#ip_address-0-ip_address"
  value       = jsonencode(google_sql_database_instance.master.ip_address)
}

output "master_instance" {
  description = "Self link to the master instance"
  value       = google_sql_database_instance.master.self_link
}

output "master_proxy_connection" {
  description = "Master instance path for connecting with Cloud SQL Proxy. Read more at https://cloud.google.com/sql/docs/mysql/sql-proxy"
  value       = "${var.project}:${var.region}:${google_sql_database_instance.master.name}"
}


# ------------------------------------------------------------------------------
# DATABASE OUTPUTS
# ------------------------------------------------------------------------------

output "db" {
  description = "Self link to the default database"
  value       = google_sql_database.default.self_link
}

output "db_name" {
  description = "Name of the default database"
  value       = google_sql_database.default.name
}

