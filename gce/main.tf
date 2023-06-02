# EDIT
locals {
  project_id = "REPLACE-YOUR-PROJECT-ID"
  region     = "us-west2"
  zone       = "us-west2-b"
}
# END EDIT

terraform {
  backend "gcs" {
    # EDIT
    bucket = "REPLACE-YOUR-PROJECT-ID-tf-state"
    # END EDIT
    prefix = "terraform/gce/state"
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
