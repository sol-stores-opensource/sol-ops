resource "kubernetes_deployment" "main" {
  wait_for_rollout = false

  lifecycle {
    ignore_changes = [
      spec.0.template.0.spec.0.container.0.image,
      spec.0.template.0.spec.0.container.0.security_context.0.capabilities,
      spec.0.template.0.spec.0.container.1.security_context.0.capabilities,
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
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.name
      }
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
          image             = "gcr.io/${var.project_id}/${var.name}:latest"
          image_pull_policy = "IfNotPresent"

          env {
            name  = "NONCE"
            value = var.nonce
          }

          port {
            container_port = var.PORT
            protocol       = "TCP"
          }

          resources {
            limits = {
              cpu               = "250m"
              memory            = "512Mi"
              ephemeral-storage = "100M"
            }
            requests = {
              cpu               = "250m"
              memory            = "512Mi"
              ephemeral-storage = "100M"
            }
          }

          readiness_probe {
            http_get {
              path   = "/nginx-health"
              port   = var.PORT
              scheme = "HTTP"
            }
            initial_delay_seconds = 20
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 1
            failure_threshold     = 3
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
        termination_grace_period_seconds = 180

      }
    }
  }
}
