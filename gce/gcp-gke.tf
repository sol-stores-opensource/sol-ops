resource "random_id" "gke_suffix" {
  byte_length = 4
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "gke-${random_id.gke_suffix.hex}"
  location = local.region

  node_locations = [local.zone]

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  ip_allocation_policy {
  }

  # Enabling Autopilot for this cluster
  enable_autopilot = true

  vertical_pod_autoscaling {
    enabled = true
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
  }

}
