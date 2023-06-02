resource "kubernetes_namespace" "main" {
  metadata {
    labels = {
      name = var.name
    }

    name = var.name
  }
}