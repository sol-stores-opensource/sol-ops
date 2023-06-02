resource "kubernetes_namespace_v1" "main" {
  metadata {
    labels = {
      name = var.name
    }

    name = var.name
  }
}