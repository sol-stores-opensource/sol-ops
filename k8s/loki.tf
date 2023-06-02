module "loki-prod" {
  source = "../modules/loki"

  name             = "loki-prod"
  k8s_namespace    = "loki-prod"
  project_id       = local.project_id
  nonce            = "1"
  app_env          = "prod"
  gke_cluster_name = local.gke_cluster_name
  region           = local.region
  ssl_domains = [
    "kiosk.REPLACE-YOUR-DOMAIN.com"
  ]
  replicas = 1
  PORT     = 8080
}

module "loki-staging" {
  source = "../modules/loki"

  name             = "loki-staging"
  k8s_namespace    = "loki-staging"
  project_id       = local.project_id
  nonce            = "1"
  app_env          = "staging"
  gke_cluster_name = local.gke_cluster_name
  region           = local.region
  ssl_domains = [
    "loki-staging.internal.REPLACE-YOUR-DOMAIN.com"
  ]
  replicas = 1
  PORT     = 8080
}
