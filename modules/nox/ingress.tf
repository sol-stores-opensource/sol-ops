resource "google_compute_global_address" "main" {
  name = "${var.name}-ip"
}

output "ip" {
  value = google_compute_global_address.main.address
}

resource "kubernetes_manifest" "managed-cert" {
  manifest = {
    "apiVersion" = "networking.gke.io/v1"
    "kind"       = "ManagedCertificate"
    "metadata" = {
      "name"      = "${var.name}-managed-cert"
      "namespace" = kubernetes_namespace.main.metadata[0].name
    }
    "spec" = {
      "domains" = var.ssl_domains
    }
  }

}

resource "kubernetes_manifest" "frontend-config" {
  manifest = {
    "apiVersion" = "networking.gke.io/v1beta1"
    "kind"       = "FrontendConfig"
    "metadata" = {
      "name"      = "${var.name}-frontend-config"
      "namespace" = kubernetes_namespace.main.metadata[0].name
    }
    "spec" = {
      "redirectToHttps" = {
        # seems Managed Certificate SSL will fail if this is enabled, not sure the workaround yet
        "enabled"          = false
        "responseCodeName" = "MOVED_PERMANENTLY_DEFAULT"
      }
    }
  }

}

resource "kubernetes_ingress" "main" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.main.metadata[0].name

    labels = {
      app = var.name
    }

    annotations = {
      "kubernetes.io/ingress.global-static-ip-name" = google_compute_global_address.main.name
      "networking.gke.io/managed-certificates"      = kubernetes_manifest.managed-cert.manifest.metadata.name
      "networking.gke.io/v1beta1.FrontendConfig"    = kubernetes_manifest.frontend-config.manifest.metadata.name
      "kubernetes.io/ingress.class"                 = "gce"
    }
  }

  spec {
    rule {
      http {
        path {
          backend {
            service_name = var.name
            service_port = 80
          }
          path = "/*"
        }
      }
    }
  }

}
