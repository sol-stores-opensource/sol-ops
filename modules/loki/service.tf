resource "kubernetes_service" "main" {

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cloud.google.com/neg"],
      metadata[0].annotations["cloud.google.com/neg-status"],
    ]
  }

  metadata {
    labels = {
      app = var.name
    }
    name      = var.name
    namespace = kubernetes_namespace.main.metadata[0].name
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
