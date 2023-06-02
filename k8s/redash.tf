resource "google_sql_database" "redash_database" {
  name     = "redash"
  instance = google_sql_database_instance.pg_ops_main.name
}

resource "google_sql_user" "pg_ops_main_redash" {
  instance        = google_sql_database_instance.pg_ops_main.name
  name            = "redash"
  password        = "REPLACE-WITH-PASSWORD"
  deletion_policy = "ABANDON"
}

locals {
  redash_domain_name = "redash.internal.REPLACE-YOUR-DOMAIN.com"

}

module "redash" {
  source = "../modules/redash"

  name               = "redash"
  k8s_namespace      = "redash"
  project_id         = local.project_id
  db_connection_name = google_sql_database_instance.pg_ops_main.connection_name
  domain_name        = local.redash_domain_name
  image              = "redash/redash@sha256:3d93b17724b7b050ed253b67998af4bc6bae4a054a69e17944208054767f9185"
  replicas           = 1
  container_env = {
    REDASH_LOG_LEVEL                        = "INFO"
    REDASH_GUNICORN_TIMEOUT                 = "600"
    WORKERS_COUNT                           = "4"
    QUEUES                                  = "periodic emails default scheduled_queries queries schemas"
    REDASH_REDIS_URL                        = "redis://localhost:6379/0"
    PYTHONUNBUFFERED                        = "0"
    REDASH_COOKIE_SECRET                    = "REPLACE-WITH-SECRET-UUID"
    REDASH_DATABASE_URL                     = "postgresql://${google_sql_user.pg_ops_main_redash.name}:${google_sql_user.pg_ops_main_redash.password}@localhost:5432/${google_sql_database.redash_database.name}"
    REDASH_HOST                             = "https://${local.redash_domain_name}"
    REDASH_NAME                             = "Nox Redash"
    REDASH_MAIL_SERVER                      = "REPLACE"
    REDASH_MAIL_PORT                        = "587"
    REDASH_MAIL_USERNAME                    = "REPLACE"
    REDASH_MAIL_PASSWORD                    = "REPLACE"
    REDASH_MAIL_DEFAULT_SENDER              = "REPLACE-FROM-EMAIL-ADDRESS"
    REDASH_MAIL_USE_TLS                     = "true"
    REDASH_GOOGLE_CLIENT_ID                 = "REPLACE-.apps.googleusercontent.com"
    REDASH_GOOGLE_CLIENT_SECRET             = "REPLACE"
    REDASH_PASSWORD_LOGIN_ENABLED           = "false"
    REDASH_ENABLED_QUERY_RUNNERS            = "redash.query_runner.big_query,redash.query_runner.google_spreadsheets,redash.query_runner.pg,redash.query_runner.url,redash.query_runner.sqlite,redash.query_runner.google_analytics,redash.query_runner.query_results,redash.query_runner.excel,redash.query_runner.csv"
    REDASH_ENABLED_DESTINATIONS             = "redash.destinations.email,redash.destinations.slack,redash.destinations.webhook"
    REDASH_CORS_ACCESS_CONTROL_ALLOW_ORIGIN = "nox.REPLACE-YOUR-DOMAIN.com"
  }
}


