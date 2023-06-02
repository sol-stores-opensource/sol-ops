resource "google_service_account" "bigqueryreader" {
  account_id   = "${var.name}-bigqueryreader"
  display_name = "${var.name}-bigqueryreader"
  project      = var.project_id
}

resource "google_project_iam_member" "bigqueryreader_bindings" {
  for_each = toset([
    "roles/bigquery.dataViewer",
    "roles/bigquery.metadataViewer",
    "roles/bigquery.jobUser"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.bigqueryreader.email}"
}

resource "google_service_account_key" "bigqueryreader" {
  service_account_id = google_service_account.bigqueryreader.name
}

output "bigqueryreader_json_key" {
  value = base64decode(google_service_account_key.bigqueryreader.private_key)
}
