resource "google_sql_database" "nox_staging_database" {
  name     = "nox_staging"
  instance = google_sql_database_instance.pg_ops_main.name
}

resource "google_sql_user" "pg_ops_main_nox_staging" {
  instance        = google_sql_database_instance.pg_ops_main.name
  name            = "nox_staging"
  password        = "REPLACE-PASSWORD"
  deletion_policy = "ABANDON"
}

locals {
  nox_staging_port                    = 4000
  nox_staging_uploads_bucket_location = "US"
  nox_staging_uploads_bucket_name     = "nox-staging-uploads"
}

module "nox-staging" {
  source = "../modules/k8s-app"

  name                    = "nox-staging"
  project_id              = local.project_id
  gke_cluster_name        = local.gke_cluster_name
  region                  = local.region
  github_owner            = "REPLACE-WITH-GITHUB-OWNER"
  github_name             = "REPLACE-WITH-GITHUB-NAME"
  github_deploy_branch    = "^release-staging$"
  service_account_roles = [
    "roles/cloudsql.admin",
    "roles/cloudsql.client",
    "roles/cloudsql.editor",
    "roles/bigquery.admin",
    "roles/bigquery.dataOwner",
    "roles/storage.admin"
  ]

  ssl_domains = [
    "nox-staging.internal.REPLACE-YOUR-DOMAIN.com"
  ]

  replicas = 5
  PORT     = local.nox_staging_port
  cpu      = "250m"
  memory   = "512Mi"

  container_env = {
    NONCE                      = "1"
    DATABASE_URL               = "ecto://${google_sql_user.pg_ops_main_nox_staging.name}:${google_sql_user.pg_ops_main_nox_staging.password}@${google_sql_database_instance.pg_ops_main.private_ip_address}:5432/${google_sql_database.nox_staging_database.name}"
    PORT                       = local.nox_staging_port
    SECRET_KEY_BASE            = "REPLACE"
    AUTH_GOOGLE_CLIENT_ID      = "REPLACE-.apps.googleusercontent.com"
    AUTH_GOOGLE_CLIENT_SECRET  = "REPLACE"
    MUX_ACCESS_TOKEN_ID        = "REPLACE"
    MUX_ACCESS_TOKEN_SECRET    = "REPLACE"
    MUX_WEBHOOK_SECRET         = "REPLACE"
    DECAF_SHOP_ID              = "REPLACE"
    DECAF_AIRDROP_API_URL      = "https://api-dev.decaf.so/solanaNFTAirdropAPI"
    COLLECT_DATASET            = "nox_staging"
    COLLECT_TABLE              = "collect"
    POOL_SIZE                  = "10"
    PHX_HOST                   = "nox-staging.internal.REPLACE-YOUR-DOMAIN.com"
    UPLOADS_BUCKET             = local.nox_staging_uploads_bucket_name
    TUTS_URL_BASE              = "https://tuts-staging.internal.REPLACE-YOUR-DOMAIN.com"
    NOX_DATASET                = "nox_staging"
    solana_rpc_url             = "https://api.mainnet-beta.solana.com"
    bundlr_address             = "https://node1.bundlr.network"
    cloak_vault_key            = "REPLACE"
    decaf_le_config_api_key    = "REPLACE"
    decaf_le_config_api_url    = "REPLACE"
    decaf_le_solana_qr_url     = "REPLACE"
    helius_api_key             = "REPLACE"
    nox_warn_deploy_env        = "staging"
  }
}


module "nox-staging-specific" {
  source = "../modules/nox-specific"

  name                    = "nox-staging"
  project_id              = local.project_id
  uploads_bucket_location = local.nox_staging_uploads_bucket_location
  uploads_bucket_name     = local.nox_staging_uploads_bucket_name
}
output "nox-staging-bigqueryreader_json_key" {
  sensitive = true
  value     = module.nox-staging-specific.bigqueryreader_json_key
}

output "nox-staging-dbt-sa-json-key" {
  sensitive = true
  value     = module.nox-staging-specific.dbt-sa-json-key
}
