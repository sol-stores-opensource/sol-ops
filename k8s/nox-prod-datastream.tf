### SETUP
#
# intially set `desired_state = "NOT_STARTED"`
#
# after db user is provisioned, run:
#
# as nox_prod:
#
#   alter role nox_prod_repl with REPLICATION NOCREATEDB NOCREATEROLE ;
#   GRANT SELECT ON ALL TABLES IN SCHEMA public TO nox_prod_repl;
#   GRANT USAGE ON SCHEMA public TO nox_prod_repl;
#   ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO nox_prod_repl;
#   CREATE PUBLICATION "publication" FOR TABLE "le_partners", "le_rewards", "stores", "tut_pages", "tutorials", "tutorial_stores", "users";
#   # to later remove a table from the publication, run:
#   # ALTER PUBLICATION "publication" DROP TABLE "table_name";
#   # to later add a table to the publication, run:
#   # ALTER PUBLICATION "publication" ADD TABLE "table_name";
#
# as nox_prod_repl:
#
#   SELECT PG_CREATE_LOGICAL_REPLICATION_SLOT ('replication_slot', 'pgoutput');
#
# then re-run terraform with `desired_state = "RUNNING"`
#
###

resource "google_sql_user" "pg_ops_main_nox_prod_repl" {
  instance        = google_sql_database_instance.pg_ops_main.name
  name            = "nox_prod_repl"
  password        = "REPLACE-WITH-REPL-PASSWORD"
  deletion_policy = "ABANDON"
}

resource "google_datastream_connection_profile" "nox_prod_source" {
  display_name          = "nox-prod-pg-source"
  location              = local.region
  connection_profile_id = "nox-prod-pg-source"

  postgresql_profile {
    hostname = google_sql_database_instance.pg_ops_main.public_ip_address
    port     = 5432
    username = google_sql_user.pg_ops_main_nox_prod_repl.name
    password = google_sql_user.pg_ops_main_nox_prod_repl.password
    database = google_sql_database.nox_prod_database.name
  }
}

resource "google_datastream_connection_profile" "nox_prod_destination" {
  display_name          = "nox-prod-bq-dest"
  location              = local.region
  connection_profile_id = "nox-prod-bq-dest"

  bigquery_profile {}
}

resource "google_bigquery_dataset" "nox_prod_bq_dataset" {
  dataset_id    = "nox_prod_cdc"
  friendly_name = "nox_prod_cdc"
  description   = "nox_prod_cdc"
  location      = "US"
}

resource "google_datastream_stream" "nox_prod" {
  display_name  = "nox-prod-pg-to-bq"
  location      = local.region
  stream_id     = "nox-prod-pg-to-bq"
  desired_state = "RUNNING"
  # desired_state = "NOT_STARTED"
  # desired_state = "PAUSED"

  source_config {
    source_connection_profile = google_datastream_connection_profile.nox_prod_source.id
    postgresql_source_config {
      # max_concurrent_backfill_tasks = 12
      publication      = "publication"
      replication_slot = "replication_slot"
      include_objects {
        postgresql_schemas {
          schema = "public"
          postgresql_tables {
            table = "le_partners"
          }
          postgresql_tables {
            table = "le_rewards"
          }
          postgresql_tables {
            table = "stores"
          }
          postgresql_tables {
            table = "tut_pages"
          }
          postgresql_tables {
            table = "tutorials"
          }
          postgresql_tables {
            table = "tutorial_stores"
          }
          postgresql_tables {
            table = "users"
          }
        }
      }
    }
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.nox_prod_destination.id
    bigquery_destination_config {
      data_freshness = "60s"
      single_target_dataset {
        dataset_id = replace(replace(google_bigquery_dataset.nox_prod_bq_dataset.id, "projects/", ""), "/\\/datasets\\//", ":")
      }
    }
  }

  backfill_all {}
}