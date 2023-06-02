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

resource "google_project_iam_member" "workload_identity_sa_bindings" {
  for_each = toset(var.service_account_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.main.email}"
}

resource "google_service_account_key" "main" {
  service_account_id = google_service_account.main.name
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

resource "kubernetes_role" "main" {
  metadata {
    name      = "${var.name}-role"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "main" {
  metadata {
    name      = "${var.name}-rolebinding"
    namespace = kubernetes_namespace.main.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "${var.name}-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.main.metadata[0].name
    namespace = kubernetes_namespace.main.metadata[0].name
  }
}
