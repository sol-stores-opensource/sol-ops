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
      "namespace" = var.k8s_namespace
    }
    "spec" = {
      "domains" = [
        var.domain_name
      ]
    }
  }

}

resource "kubernetes_manifest" "frontend-config" {
  manifest = {
    "apiVersion" = "networking.gke.io/v1beta1"
    "kind"       = "FrontendConfig"
    "metadata" = {
      "name"      = "${var.name}-frontend-config"
      "namespace" = var.k8s_namespace
    }
    "spec" = {
      "redirectToHttps" = {
        "enabled"          = true
        "responseCodeName" = "MOVED_PERMANENTLY_DEFAULT"
      }
    }
  }

}

resource "kubernetes_ingress_v1" "main" {
  metadata {
    name      = var.name
    namespace = var.k8s_namespace

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
      host = var.domain_name
      http {
        path {
          backend {
            service {
              name = var.name
              port {
                number = 80
              }
            }
          }
          path = "/*"
        }
      }
    }
  }

}
