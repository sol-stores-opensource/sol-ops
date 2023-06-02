resource "google_project_service" "enabled_apis" {
  for_each = toset([
    "bigquery.googleapis.com",
    "dns.googleapis.com",
    "cloudkms.googleapis.com",
    "logging.googleapis.com",
    "pubsub.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage-component.googleapis.com",
    "sqladmin.googleapis.com",
    "compute.googleapis.com",
    "containerregistry.googleapis.com",
    "iam.googleapis.com",
    "container.googleapis.com",
    "serviceusage.googleapis.com",
    "clouderrorreporting.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
    "run.googleapis.com",
    "cloudfunctions.googleapis.com",
    "artifactregistry.googleapis.com",
    "servicenetworking.googleapis.com",
    "datastream.googleapis.com",
    "alloydb.googleapis.com",
    "datamigration.googleapis.com"
  ])

  service = each.key

  project = local.project_id

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = false
  disable_on_destroy         = false
}
