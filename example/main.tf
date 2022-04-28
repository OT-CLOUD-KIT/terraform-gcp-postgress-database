module "gcp_postgres" {
  source           = "../"
  name             = "terraform-postgres3"
  database_version = "POSTGRES_14"
  deletion_protection = "false"
  ip_configuration = {
    ipv4_enabled        = true
    private_network     = null
    require_ssl         = null
    allocated_ip_range  = null  
    authorized_networks = [{
        name = "self"
        value = "103.46.200.207/32"
    }]
  }
  users = [
    {
      name     = "postgres"
    },
    {
      name     = "traider"
    },
  ]
  databases = [
      {
          name = "ticket"
          charset = null
          collation = null
      }
  ]
}