resource "kubernetes_manifest" "backendconfig" {
  manifest = {
    "apiVersion" = "cloud.google.com/v1"
    "kind"       = "BackendConfig"
    "metadata" = {
      "name"      = "${var.name}-backend-config"
      "namespace" = var.k8s_namespace
    }
    "spec" = {
      "timeoutSec" = 600
      "healthCheck" = {
        "checkIntervalSec" = 30
        "port"             = 5000
        "type"             = "HTTP"
        "requestPath"      = "/ping"
      }
    }
  }
}

resource "kubernetes_service" "main" {

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cloud.google.com/neg-status"],
    ]
  }

  metadata {
    labels = {
      app = var.name
    }
    name      = var.name
    namespace = var.k8s_namespace

    annotations = {
      "cloud.google.com/neg" = jsonencode(
        {
          ingress = true
        }
      )
      "cloud.google.com/backend-config" = jsonencode(
        {
          default = kubernetes_manifest.backendconfig.manifest.metadata.name
        }
      )
    }

  }

  spec {
    external_traffic_policy = "Local"

    port {
      name        = "http"
      port        = 80
      protocol    = "TCP"
      target_port = 5000
    }
    selector = {
      app = var.name
    }
    type = "NodePort"
  }

}
