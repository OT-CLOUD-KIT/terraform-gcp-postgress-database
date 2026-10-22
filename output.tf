output "master_instance_name" {
  description = "Name of the primary Cloud SQL instance."
  value       = google_sql_database_instance.master.name
}

output "master_private_ip_address" {
  description = "Private IPv4 address of the primary instance."
  value       = google_sql_database_instance.master.private_ip_address
}

output "master_public_ip_address" {
  description = "Public IPv4 address of the primary instance, if enabled."
  value       = google_sql_database_instance.master.public_ip_address
}

output "master_ip_addresses" {
  description = "All IP address objects assigned to the primary instance."
  value       = google_sql_database_instance.master.ip_address
}

output "master_instance" {
  description = "Self-link of the primary instance."
  value       = google_sql_database_instance.master.self_link
}

output "master_connection_name" {
  description = "Connection name used by Cloud SQL connectors and the Auth Proxy."
  value       = google_sql_database_instance.master.connection_name
}

output "master_proxy_connection" {
  description = "Deprecated alias of master_connection_name."
  value       = google_sql_database_instance.master.connection_name
}

output "db" {
  description = "Self-link of the application database."
  value       = google_sql_database.default.self_link
}

output "db_name" {
  description = "Name of the application database."
  value       = google_sql_database.default.name
}

output "read_replica_names" {
  description = "Names of the PostgreSQL read replicas."
  value       = google_sql_database_instance.read_replica[*].name
}

output "service_account_email_address" {
  description = "Cloud SQL service identity. Grant this identity KMS encrypt/decrypt permission before enabling CMEK."
  value       = google_sql_database_instance.master.service_account_email_address
}
