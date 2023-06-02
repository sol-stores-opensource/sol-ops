resource "kubernetes_secret" "secrets" {

  metadata {
    name      = "secrets"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  data = {
    "google-sa.json" = base64decode(google_service_account_key.main.private_key)
  }

  type = "Opaque"
}