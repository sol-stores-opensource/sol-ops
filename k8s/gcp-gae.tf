resource "google_app_engine_application" "app" {
  project       = local.project_id
  location_id   = local.region
  database_type = "CLOUD_FIRESTORE"
}
