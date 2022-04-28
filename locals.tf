locals {
  retained_backups = lookup(var.backup_configuration, "retained_backups", null)
  retention_unit   = lookup(var.backup_configuration, "retention_unit", null)
  databases        = { for db in var.databases : db.name => db }
  users            = { for u in var.users : u.name => u }
}
