module "tuts-prod" {
  source = "../modules/tuts"

  name             = "tuts-prod"
  k8s_namespace    = "tuts-prod"
  project_id       = local.project_id
  nonce            = "1"
  app_env          = "prod"
  gke_cluster_name = local.gke_cluster_name
  region           = local.region
  ssl_domains = [
    "partner-tutorials.REPLACE-YOUR-DOMAIN.com"
  ]
  replicas = 1
  PORT     = 8080
}

module "tuts-staging" {
  source = "../modules/tuts"

  name             = "tuts-staging"
  k8s_namespace    = "tuts-staging"
  project_id       = local.project_id
  nonce            = "1"
  app_env          = "staging"
  gke_cluster_name = local.gke_cluster_name
  region           = local.region
  ssl_domains = [
    "tuts-staging.internal.REPLACE-YOUR-DOMAIN.com"
  ]
  replicas = 1
  PORT     = 8080
}
