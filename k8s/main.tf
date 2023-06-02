# EDIT
locals {
  project_id                          = "REPLACE-YOUR-PROJECT-ID"
  region                              = "us-west2"
  zone                                = "us-west2-b"
  gke_cluster_name                    = "REPLACE-YOUR-GKE-CLUSTER"
  postgres_postgres_pw                = "REPLACE"
}
# END EDIT

terraform {
  backend "gcs" {
    # EDIT
    bucket = "REPLACE-YOUR-PROJECT-ID-tf-state"
    # END EDIT
    prefix = "terraform/k8s/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.55.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.55.0"
    }
  }

  required_version = ">= 1.3.9"
}

provider "google" {
  project = local.project_id
  region                = local.region
  user_project_override = true
}

provider "google-beta" {
  project = local.project_id
  region                = local.region
  user_project_override = true
}

data "google_client_config" "default" {
}

data "google_container_cluster" "primary" {
  name     = local.gke_cluster_name
  location = local.region
  project  = local.project_id
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.primary.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.primary.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
    )
  }
}
resource "kubernetes_secret" "testingsecret1" {

  metadata {
    name      = "testingsecret1"
    namespace = "default"
  }

  data = {
    "foo" = "bar"
  }

  type = "Opaque"
}
