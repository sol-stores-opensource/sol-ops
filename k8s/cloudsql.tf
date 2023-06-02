resource "google_service_account" "cloud-sql" {
  account_id   = "cloud-sql"
  display_name = "cloud-sql"
  project      = local.project_id
}

resource "google_project_iam_member" "cloud-sql-admin" {
  member  = "serviceAccount:${google_service_account.cloud-sql.email}"
  project = local.project_id
  role    = "roles/cloudsql.admin"
}

resource "google_project_iam_member" "cloud-sql-client" {
  member  = "serviceAccount:${google_service_account.cloud-sql.email}"
  project = local.project_id
  role    = "roles/cloudsql.client"
}

resource "google_project_iam_member" "cloud-sql-editor" {
  member  = "serviceAccount:${google_service_account.cloud-sql.email}"
  project = local.project_id
  role    = "roles/cloudsql.editor"
}

resource "google_service_account_key" "cloud-sql" {
  service_account_id = google_service_account.cloud-sql.name
}

resource "kubernetes_secret" "cloudsql-credentials" {

  metadata {
    name      = "cloudsql-credentials"
    namespace = "default"
  }

  data = {
    "credentials.json" = base64decode(google_service_account_key.cloud-sql.private_key)
    "pg_ops_main"      = google_sql_database_instance.pg_ops_main.connection_name
  }

  type = "Opaque"
}
