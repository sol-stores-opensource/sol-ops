resource "google_service_account" "main" {
  account_id   = "${var.name}-sa"
  display_name = "${var.name}-sa"
  project      = var.project_id
}

resource "google_service_account_iam_member" "workload_identify_main" {
  service_account_id = google_service_account.main.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_namespace.main.metadata[0].name}/${var.name}-sa]"
}

resource "kubernetes_service_account" "main" {
  metadata {
    name      = "${var.name}-sa"
    namespace = kubernetes_namespace.main.metadata[0].name
    labels = {
      app = var.name
    }
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.main.email
    }
  }
}
