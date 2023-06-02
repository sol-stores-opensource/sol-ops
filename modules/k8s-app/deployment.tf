resource "kubernetes_deployment" "main" {

  wait_for_rollout = false

  lifecycle {
    ignore_changes = [
      spec.0.replicas,
      spec.0.template.0.spec.0.toleration,
      spec.0.template.0.spec.0.container.0.image,
      spec.0.template.0.spec.0.container.0.security_context.0.capabilities,
      metadata.0.annotations["autopilot.gke.io/resource-adjustment"]
    ]
  }
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.main.metadata[0].name
    labels = {
      app = var.name
    }
  }

  spec {
    replicas               = var.replicas
    revision_history_limit = 3
    min_ready_seconds      = 10

    selector {
      match_labels = {
        app = var.name
      }
    }

    strategy {
      rolling_update {
        max_surge       = "100%"
        max_unavailable = "0"
      }
      type = "RollingUpdate"
    }

    template {
      metadata {
        name = var.name
        labels = {
          app = var.name
        }
      }

      spec {

        container {
          name              = var.name
          image             = "noop"
          image_pull_policy = "IfNotPresent"

          env {
            name  = "MY_K8S_APP"
            value = var.name
          }

          env {
            name  = "MY_K8S_NAMESPACE"
            value = kubernetes_namespace.main.metadata[0].name
          }

          env {
            name = "MY_POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          volume_mount {
            name       = "secrets"
            mount_path = "/secrets"
            read_only  = true
          }

          port {
            container_port = var.PORT
            protocol       = "TCP"
          }

          resources {
            requests = {
              cpu               = var.cpu
              memory            = var.memory
              ephemeral-storage = "100M"
            }
            limits = {
              cpu               = var.cpu
              memory            = var.memory
              ephemeral-storage = "100M"
            }
          }

          startup_probe {
            http_get {
              path   = var.health_startup_path
              port   = var.PORT
              scheme = "HTTP"
            }
            initial_delay_seconds = 10
            period_seconds        = 3
            success_threshold     = 1
            timeout_seconds       = 5
            failure_threshold     = 40
          }
          readiness_probe {
            http_get {
              path   = var.health_readiness_path
              port   = var.PORT
              scheme = "HTTP"
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 5
            failure_threshold     = 5
          }
          liveness_probe {
            http_get {
              path   = var.health_liveness_path
              port   = var.PORT
              scheme = "HTTP"
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 5
            failure_threshold     = 5
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false
            run_as_non_root            = false
          }

        }

        service_account_name = kubernetes_service_account.main.metadata[0].name
        dns_policy           = "ClusterFirst"
        restart_policy       = "Always"
        security_context {
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
        termination_grace_period_seconds = 60

        volume {
          name = "secrets"
          secret {
            default_mode = "0444"
            secret_name  = kubernetes_secret.secrets.metadata[0].name
          }
        }
      }
    }
  }
}
