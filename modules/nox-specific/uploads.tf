resource "google_storage_bucket" "uploads" {
  default_event_based_hold    = "false"
  force_destroy               = "false"
  location                    = var.uploads_bucket_location
  name                        = var.uploads_bucket_name
  project                     = var.project_id
  requester_pays              = "false"
  storage_class               = "MULTI_REGIONAL"
  uniform_bucket_level_access = "false"
}
