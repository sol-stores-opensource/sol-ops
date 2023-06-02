resource "kubernetes_namespace" "main" {
  metadata {
    labels = {
      name = var.k8s_namespace
    }

    name = var.k8s_namespace
  }
}