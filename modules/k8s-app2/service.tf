resource "kubernetes_manifest" "backendconfig" {
  manifest = {
    "apiVersion" = "cloud.google.com/v1"
    "kind"       = "BackendConfig"
    "metadata" = {
      "name"      = "${var.name}-backend-config"
      "namespace" = var.name
    }
    "spec" = {
      "timeoutSec" = 600
    }
  }
}

resource "kubernetes_service_v1" "main" {
  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cloud.google.com/neg"],
      metadata[0].annotations["cloud.google.com/neg-status"]
    ]
  }

  metadata {
    labels = {
      app = var.name
    }
    name      = var.name
    namespace = kubernetes_namespace_v1.main.metadata[0].name

    annotations = {
      "cloud.google.com/backend-config" = jsonencode(
        {
          default = kubernetes_manifest.backendconfig.manifest.metadata.name
        }
      )
    }

  }

  spec {
    port {
      name        = "http"
      port        = 80
      protocol    = "TCP"
      target_port = var.PORT
    }
    selector = {
      app = var.name
    }
  }

}
