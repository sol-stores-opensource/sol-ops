resource "google_sql_database" "nox_prod_database" {
  name     = "nox_prod"
  instance = google_sql_database_instance.pg_ops_main.name
}

resource "google_sql_user" "pg_ops_main_nox_prod" {
  instance        = google_sql_database_instance.pg_ops_main.name
  name            = "nox_prod"
  password        = "REPLACE-PASSWORD"
  deletion_policy = "ABANDON"
}

locals {
  nox_prod_port                    = 4000
  nox_prod_uploads_bucket_location = "US"
  nox_prod_uploads_bucket_name     = "nox-prod-uploads"
}

module "nox-prod" {
  source = "../modules/k8s-app"

  name                    = "nox-prod"
  project_id              = local.project_id
  gke_cluster_name        = local.gke_cluster_name
  region                  = local.region
  github_owner            = "REPLACE-WITH-GITHUB-OWNER"
  github_name             = "REPLACE-WITH-GITHUB-NAME"
  github_deploy_branch    = "^release-prod$"
  service_account_roles = [
    "roles/cloudsql.admin",
    "roles/cloudsql.client",
    "roles/cloudsql.editor",
    "roles/bigquery.admin",
    "roles/bigquery.dataOwner",
    "roles/storage.admin"
  ]
  ssl_domains = [
    "nox.REPLACE-YOUR-DOMAIN.com"
  ]
  replicas = 2
  PORT     = local.nox_prod_port
  cpu      = "1"
  memory   = "2Gi"
  container_env = {
    NONCE                      = "1"
    DATABASE_URL               = "ecto://${google_sql_user.pg_ops_main_nox_prod.name}:${google_sql_user.pg_ops_main_nox_prod.password}@${google_sql_database_instance.pg_ops_main.private_ip_address}:5432/${google_sql_database.nox_prod_database.name}"
    PORT                       = local.nox_prod_port
    SECRET_KEY_BASE            = "REPLACE"
    AUTH_GOOGLE_CLIENT_ID      = "REPLACE-.apps.googleusercontent.com"
    AUTH_GOOGLE_CLIENT_SECRET  = "REPLACE"
    MUX_ACCESS_TOKEN_ID        = "REPLACE"
    MUX_ACCESS_TOKEN_SECRET    = "REPLACE"
    MUX_WEBHOOK_SECRET         = "REPLACE"
    DECAF_SHOP_ID              = "REPLACE"
    DECAF_AIRDROP_API_URL      = "https://api.decaf.so/solanaNFTAirdropAPI"
    COLLECT_DATASET            = "nox_prod"
    COLLECT_TABLE              = "collect"
    POOL_SIZE                  = "30"
    PHX_HOST                   = "nox.REPLACE-YOUR-DOMAIN.com"
    UPLOADS_BUCKET             = local.nox_prod_uploads_bucket_name
    TUTS_URL_BASE              = "https://partner-tutorials.REPLACE-YOUR-DOMAIN.com"
    NOX_DATASET                = "nox_prod"
    solana_rpc_url             = "https://api.mainnet-beta.solana.com"
    bundlr_address             = "https://node1.bundlr.network"
    cloak_vault_key            = "REPLACE"
    decaf_le_config_api_key    = "REPLACE"
    decaf_le_config_api_url    = "REPLACE"
    decaf_le_solana_qr_url     = "REPLACE"
    helius_api_key             = "REPLACE"
  }
}

module "nox-prod-specific" {
  source = "../modules/nox-specific"

  name                    = "nox-prod"
  project_id              = local.project_id
  uploads_bucket_location = local.nox_prod_uploads_bucket_location
  uploads_bucket_name     = local.nox_prod_uploads_bucket_name
}

output "nox-prod-bigqueryreader_json_key" {
  sensitive = true
  value     = module.nox-prod-specific.bigqueryreader_json_key
}

output "nox-prod-dbt-sa-json-key" {
  sensitive = true
  value     = module.nox-prod-specific.dbt-sa-json-key
}
