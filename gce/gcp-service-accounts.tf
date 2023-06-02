# cloudbuild using generated sa

resource "google_project_service_identity" "cloudbuild" {
  provider = google-beta

  project = data.google_project.project.project_id
  service = "cloudbuild.googleapis.com"
}

resource "google_project_iam_member" "cloudbuild_builder" {
  project = local.project_id
  member  = "serviceAccount:${google_project_service_identity.cloudbuild.email}"
  role    = "roles/cloudbuild.builds.builder"
}

resource "google_project_iam_member" "cloudbuild_crypto" {
  project = local.project_id
  member  = "serviceAccount:${google_project_service_identity.cloudbuild.email}"
  role    = "roles/cloudkms.cryptoKeyDecrypter"
}

resource "google_project_iam_member" "cloudbuild_container_admin" {
  project = local.project_id
  member  = "serviceAccount:${google_project_service_identity.cloudbuild.email}"
  role    = "roles/container.admin"
}


resource "google_project_iam_member" "cloudbuild_funnctions" {
  # roles/iam.serviceAccountUser
  # roles/cloudfunctions.serviceAgent
  # roles/eventarc.serviceAgent
  # roles/run.serviceAgent
  # roles/serverless.serviceAgent
  for_each = toset([
    "roles/cloudfunctions.developer",
    "roles/run.admin",
    "roles/cloudfunctions.serviceAgent"
  ])

  project = local.project_id
  member  = "serviceAccount:${google_project_service_identity.cloudbuild.email}"
  role    = each.key
}

# needed for gke workload identity

resource "google_project_iam_member" "gke_sa_workload_identity" {
  project = local.project_id
  member  = "serviceAccount:${local.project_id}.svc.id.goog[default/default]"
  role    = "roles/iam.workloadIdentityUser"

  depends_on = [
    google_container_cluster.primary
  ]
}
