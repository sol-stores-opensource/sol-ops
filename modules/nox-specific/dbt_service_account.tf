resource "google_service_account" "dbt-sa" {
  account_id   = "${var.name}-dbt-sa"
  display_name = "${var.name}-dbt-sa"
  project      = var.project_id
}

resource "google_project_iam_member" "dbt-sa-bindings" {
  for_each = toset([
    "roles/bigquery.dataEditor",
    "roles/bigquery.user"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.dbt-sa.email}"
}

resource "google_service_account_key" "dbt-sa" {
  service_account_id = google_service_account.dbt-sa.name
}

output "dbt-sa-json-key" {
  value = base64decode(google_service_account_key.dbt-sa.private_key)
}
