# GCP Postgress Terraform Module

[![Opstree Solutions][opstree_avatar]][opstree_homepage]

[Opstree Solutions][opstree_homepage]

[opstree_homepage]: https://opstree.github.io/
[opstree_avatar]: https://img.cloudposse.com/150x150/https://github.com/opstree.png

Cloud SQL for PostgreSQL is a fully-managed database service that helps you set up, maintain, manage, and administer your PostgreSQL relational databases on Google Cloud Platform.

This module provides you the functionality of Standalone Postgress.

**Note : For more information, you can check example folder.**

## AWS versions

GCP 4.19.0       
## Resources

| Name                                                                                                                               | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [google_sql_database_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance)       | Resource    |
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | Data    |
| [google_sql_database](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | Resource    |
| [google_sql_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy)              | Resource |
| [null_resource](https://www.terraform.io/language/resources/provisioners/null_resource)              | Resource |
| [template_file](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file)                                | Data Source |

## Inputs

| Name                             | Description                                                                                                                                                          | Type           | Default | Required |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------- | :------: |
| project           | The project ID to host the database in.                                                                                                                                                        | `list(string)`       |         |   Yes    |
| region                         | The region to host the database in.                                                                                                                                                        | `list(string)` |         |   Yes    |
| name_prefix                     | The name prefix for the database instance. Will be appended with a random string. Use lowercase letters, numbers, and hyphens. Start with a letter.                                                                                                                                          | `list(string)`       |         |   Yes    |
| engine             | The engine version of the database                                                                                                                                                 | `number`       |         |   Yes    |
| machine_type                             | The machine type for the instances. repository.                                                                                                                                      | `number`       |         |   Yes    |
| db_name                             | Name of your database.                                                                                                                                     | `bool`  |         |   Yes    |
| master_user_name                 | Whether images are allowed to overwrite existing tags."The username part for the default user credentials.                   | `bool`  |         |   Yes    |
| master_user_username                 | The username part for the default user credentials.                   | `bool`  |         |   Yes    |
| master_user_password                 | The password part for the default user credentials.                   | `bool`  |         |   Yes    |
## Output

| Name | Description |
| ---- | ----------- |
| master_instance_name | The name of the master database instance. |
| master_private_ip_address | The public IPv4 address of the master instance. |
| master_ip_addresses | All IP addresses of the master instance JSON encoded. |
| master_instance | Self link to the master instance. |
| master_proxy_connection | Master instance path for connecting with Cloud SQL Proxy. |
| db | Self link to the default database |
| db_name | Name of the default database |


## Usage

```hcl
module "postgres" {
  source = "../../"

  project = var.project
  region  = var.region
  name    = local.instance_name
  db_name = var.db_name
  disk_size = var.disk_size

  engine       = var.postgres_version
  machine_type = var.machine_type

  # To make it easier to test this example, we are disabling deletion protection so we can destroy the databases
  # during the tests. By default, we recommend setting deletion_protection to true, to ensure database instances are
  # not inadvertently destroyed.
  deletion_protection = false

  # These together will construct the master_user privileges, i.e.
  # 'master_user_name'@'master_user_host' IDENTIFIED BY 'master_user_password'.
  # These should typically be set as the environment variable TF_VAR_master_user_password, etc.
  # so you don't check these into source control."
  master_user_password = var.master_user_password

  master_user_name = var.master_user_name
  master_user_host = "%"

  # Pass the private network link to the module
  private_network = google_compute_network.private_network.self_link

  # Wait for the vpc connection to complete
  dependencies = [google_service_networking_connection.private_vpc_connection.network]

  custom_labels = {
    env = "uat",
    db  = "postgress",
    version = "12"
  }
}

```

### Contributor

| [![Piyush Shailly][piyush_avatar]][piyush_homepage]<br/>[Piyush Shailly][Piyush_homepage] |
| -------------------------------------------------------------------------------------------- |

[piyush_homepage]: https://media-exp1.licdn.com/dms/image/C4E03AQE_lFtqQl0ttg/profile-displayphoto-shrink_800_800/0/1600691079547?e=1660176000&v=beta&t=gdJUDhHMIF3loe6fjDwOD6QnzZwtBrHxJ_VW5VJxCeY
[piyush_avatar]: https://avatars.githubusercontent.com/u/103646446?s=400&u=40899dc6d6f2870b115a59fc13f370d274e75d16&v=4
