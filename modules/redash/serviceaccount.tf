resource "google_service_account" "main" {
  account_id   = "${var.name}-sa"
  display_name = "${var.name}-sa"
  project      = var.project_id
}

resource "google_service_account_iam_member" "workload_identify_main" {
  service_account_id = google_service_account.main.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.name}-sa]"
}

resource "google_project_iam_member" "workload_identity_sa_bindings" {
  for_each = toset([
    "roles/cloudsql.admin",
    "roles/cloudsql.client",
    "roles/cloudsql.editor"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.main.email}"
}

resource "kubernetes_service_account" "main" {
  metadata {
    name      = "${var.name}-sa"
    namespace = var.k8s_namespace
    labels = {
      app = var.name
    }
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.main.email
    }
  }
}