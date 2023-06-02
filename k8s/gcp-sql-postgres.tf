data "google_compute_network" "vpc" {
  name = "${local.project_id}-vpc"
}

resource "random_id" "postgres_suffix" {
  byte_length = 4
}

# https://cloud.google.com/sql/docs/postgres/create-instance#gcloud
resource "google_sql_database_instance" "pg_ops_main" {
  name             = "postgres-${random_id.postgres_suffix.hex}"
  database_version = "POSTGRES_14"
  region           = local.region

  deletion_protection = false

  # https://cloud.google.com/sql/docs/mysql/instance-settings
  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier              = "db-custom-2-7680"
    disk_size         = 50
    disk_autoresize   = false
    availability_type = "ZONAL"

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 2048 # Optional
      record_application_tags = true # Optional
      record_client_address   = true # Optional
      query_plans_per_minute  = 10   # Optional
    }

    ip_configuration {
      # TODO/CHECK: possibly set public ip to false in the future
      ipv4_enabled    = "true"
      private_network = data.google_compute_network.vpc.id

      # Datastream IPs will vary by region.
      authorized_networks {
        value = "35.235.83.92"
      }

      authorized_networks {
        value = "34.94.230.251"
      }

      authorized_networks {
        value = "34.94.60.44"
      }

      authorized_networks {
        value = "34.102.102.81"
      }

      authorized_networks {
        value = "34.94.40.175"
      }
    }

    location_preference {
      zone = local.zone
    }

    backup_configuration {
      enabled    = true
      location   = local.region
      start_time = "02:00"

      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }

    }

    database_flags {
      name  = "cloudsql.logical_decoding"
      value = "on"
    }

  }
}

resource "google_sql_user" "pg_ops_main_postgres" {
  name            = "postgres"
  instance        = google_sql_database_instance.pg_ops_main.name
  password        = local.postgres_postgres_pw
  deletion_policy = "ABANDON"
}
