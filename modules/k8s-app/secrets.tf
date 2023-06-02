resource "kubernetes_secret" "secrets" {

  metadata {
    name      = "${var.name}-secrets"
    namespace = var.name
  }

  data = merge(var.container_env, {
    "google-sa.json" = base64decode(google_service_account_key.main.private_key)
  })

  type = "Opaque"
}
