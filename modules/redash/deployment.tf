resource "kubernetes_deployment" "main" {
  wait_for_rollout = false

  lifecycle {
    ignore_changes = [
      spec.0.template.0.spec.0.container.0.security_context.0.capabilities,
      spec.0.template.0.spec.0.container.1.security_context.0.capabilities,
      spec.0.template.0.spec.0.container.2.security_context.0.capabilities,
      spec.0.template.0.spec.0.container.3.security_context.0.capabilities,
      spec.0.template.0.spec.0.container.4.security_context.0.capabilities,
      spec.0.template.0.spec.0.container.0.resources.0.limits,
      spec.0.template.0.spec.0.container.1.resources.0.limits,
      spec.0.template.0.spec.0.container.2.resources.0.limits,
      spec.0.template.0.spec.0.container.3.resources.0.limits,
      spec.0.template.0.spec.0.container.4.resources.0.limits,
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
          name              = "${var.name}-server"
          image             = var.image
          args              = ["server"]
          image_pull_policy = "IfNotPresent"

          dynamic "env" {
            for_each = var.container_env
            content {
              name  = env.key
              value = env.value
            }
          }

          port {
            container_port = 5000
            protocol       = "TCP"
          }

          resources {
            requests = {
              cpu               = "1"
              memory            = "1.5Gi"
              ephemeral-storage = "100M"
            }
          }

          readiness_probe {
            http_get {
              path   = "/ping"
              port   = 5000
              scheme = "HTTP"
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          liveness_probe {
            http_get {
              path   = "/ping"
              port   = 5000
              scheme = "HTTP"
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false
            run_as_non_root            = false
          }

        }

        container {
          name              = "${var.name}-scheduler"
          image             = var.image
          args              = ["scheduler"]
          image_pull_policy = "IfNotPresent"

          dynamic "env" {
            for_each = var.container_env
            content {
              name  = env.key
              value = env.value
            }
          }

          resources {
            requests = {
              cpu               = "1"
              memory            = "1.5Gi"
              ephemeral-storage = "100M"
            }
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false
            run_as_non_root            = false
          }

        }

        container {
          name              = "${var.name}-worker"
          image             = var.image
          args              = ["worker"]
          image_pull_policy = "IfNotPresent"

          dynamic "env" {
            for_each = var.container_env
            content {
              name  = env.key
              value = env.value
            }
          }

          resources {
            requests = {
              cpu               = "1"
              memory            = "1.5Gi"
              ephemeral-storage = "100M"
            }
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false
            run_as_non_root            = false
          }

        }

        container {
          name  = "redis"
          image = "redis:3.0-alpine"
          port {
            name           = "redis"
            container_port = 6379
          }

          resources {
            requests = {
              cpu               = "750m"
              memory            = "1Gi"
              ephemeral-storage = "100M"
            }
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false
            run_as_non_root            = false
          }

        }

        container {
          name              = "cloudsql-proxy"
          image             = "gcr.io/cloudsql-docker/gce-proxy:1.29.0"
          image_pull_policy = "IfNotPresent"
          command = [
            "/cloud_sql_proxy",
            "-instances=${var.db_connection_name}=tcp:5432"
          ]

          resources {
            requests = {
              cpu               = "250m"
              memory            = "512Mi"
              ephemeral-storage = "100M"
            }
          }

          security_context {
            run_as_non_root = true
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
