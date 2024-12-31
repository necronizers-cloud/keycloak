# resource "kubernetes_manifest" "keycloak" {
#   manifest = {
#     "apiVersion" = "k8s.keycloak.org/v2alpha1"
#     "kind"       = "Keycloak"
#     "metadata" = {
#       "labels" = {
#         "app"       = "keycloak"
#         "component" = "cluster"
#       }
#       "name"      = var.cluster_name
#       "namespace" = var.namespace
#     }
#     "spec" = {
#       "db" = {
#         "url" = "jdbc:postgresql://${var.postgres_cluster_name}-rw.${var.postgres_namespace}.svc/keycloak?ssl=true&sslmode=verify-ca&sslrootcert=/mnt/cert/ca.crt&sslcert=/mnt/cert/tls.crt&sslkey=/mnt/key/tls.pk8"
#         "passwordSecret" = {
#           "key"  = "password"
#           "name" = var.keycloak_database_credentials_name
#         }
#         "poolInitialSize" = 1
#         "poolMaxSize"     = 3
#         "poolMinSize"     = 1
#         "usernameSecret" = {
#           "key"  = "username"
#           "name" = var.keycloak_database_credentials_name
#         }
#         "vendor" = "postgres"
#       }
#       "hostname" = {
#         "hostname" = "${var.host_name}.${var.cloud_domain}"
#       }
#       "http" = {
#         "tlsSecret" = "keycloak-tls"
#       }
#       "ingress" = {
#         "enabled" = false
#       }
#       "instances" = 1
#       "resources" = {
#         "limits" = {
#           "cpu"    = "500m"
#           "memory" = "1Gi"
#         }
#         "requests" = {
#           "cpu"    = "500m"
#           "memory" = "1Gi"
#         }
#       }
#       "unsupported" = {
#         "podTemplate" = {
#           "spec" = {
#             "securityContext" = {
#               "fsGroup"   = 1000
#               "runAsUser" = 1000
#             }
#             "containers" = [
#               {
#                 "volumeMounts" = [
#                   {
#                     "name"      = "keycloak-postgres-certificates"
#                     "mountPath" = "/mnt/cert"
#                   },
#                   {
#                     "name"      = "keycloak-postgres-keys"
#                     "mountPath" = "/mnt/key"
#                   }
#                 ]
#               }
#             ]
#             "volumes" = [
#               {
#                 "name" = "keycloak-postgres-certificates"
#                 "secret" = {
#                   "secretName" = "keycloak-postgresql-ssl-certificates"
#                 }
#               },
#               {
#                 "name" = "keycloak-postgres-keys"
#                 "secret" = {
#                   "secretName" = "keycloak-postgresql-ssl-key"
#                 }
#               }
#             ]
#           }
#         }
#       }
#     }
#   }
# }
#

resource "kubernetes_service" "keycloak_discovery" {
  metadata {
    name      = "keycloak-discovery"
    namespace = var.namespace
  }

  spec {
    selector = {
      app       = "keycloak"
      component = "pod"
    }
    session_affinity = "None"
    port {
      name        = "discovery"
      port        = 7800
      target_port = "discovery"
    }
    type       = "ClusterIP"
    cluster_ip = "None"
  }
}

resource "kubernetes_service" "keycloak_service" {
  metadata {
    name      = "keycloak-cluster-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app       = "keycloak"
      component = "pod"
    }
    session_affinity = "None"
    port {
      name        = "http"
      port        = 8080
      target_port = "http"
    }
    port {
      name        = "https"
      port        = 8443
      target_port = "https"
    }
    port {
      name        = "management"
      port        = 9000
      target_port = "management"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_stateful_set" "keycloak_cluster" {
  metadata {
    name      = "keycloak-cluster"
    namespace = var.namespace
    labels = {
      app       = "keycloak"
      component = "statefulset"
    }
  }
  spec {
    replicas     = 2
    service_name = ""

    selector {
      match_labels = {

        app       = "keycloak"
        component = "pod"

      }
    }

    template {
      metadata {
        labels = {

          app       = "keycloak"
          component = "pod"

        }
      }

      spec {
        container {
          name  = "keycloak"
          image = "quay.io/keycloak/keycloak:26.0.7"
          args  = ["-Djgroups.dns.query=keycloak-discovery.keycloak", "--verbose", "start"]

          env {
            name  = "KC_HOSTNAME"
            value = "${var.host_name}.${var.cloud_domain}"
          }

          dynamic "env" {
            for_each = var.keycloak_environment_variables
            content {
              name  = env.value["name"]
              value = env.value["value"]
            }
          }

          env_from {
            secret_ref {
              name = "keycloak-credentials"
            }
          }

          env {
            name  = "KC_DB"
            value = "postgres"
          }

          env {
            name = "KC_DB_USERNAME"
            value_from {
              secret_key_ref {
                name = "keycloak-database-credentials"
                key  = "username"
              }
            }
          }

          env {
            name = "KC_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "keycloak-database-credentials"
                key  = "password"
              }
            }
          }

          dynamic "port" {
            for_each = var.keycloak_ports
            content {
              name           = port.value["name"]
              container_port = port.value["containerPort"]
              protocol       = port.value["protocol"]
            }
          }

          startup_probe {
            failure_threshold = 3
            http_get {
              path   = "/health/started"
              port   = "management"
              scheme = "HTTPS"
            }
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 10
            initial_delay_seconds = 90
          }

          readiness_probe {
            failure_threshold = 3
            http_get {
              path   = "/health/ready"
              port   = "management"
              scheme = "HTTPS"
            }
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 10
            initial_delay_seconds = 90
          }

          liveness_probe {
            failure_threshold = 3
            http_get {
              path   = "/health/live"
              port   = "management"
              scheme = "HTTPS"
            }
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 10
            initial_delay_seconds = 90
          }

          resources {
            requests = {
              "cpu"    = "500m"
              "memory" = "1Gi"
            }

            limits = {
              "cpu"    = "500m"
              "memory" = "1Gi"
            }
          }

          dynamic "volume_mount" {
            for_each = var.keycloak_volume_mounts
            content {
              name       = volume_mount.value["name"]
              mount_path = volume_mount.value["mountPath"]
            }
          }

        }

        dynamic "volume" {
          for_each = var.keycloak_volumes
          content {
            name = volume.value["name"]
            secret {
              secret_name = volume.value["secretName"]
            }
          }
        }

        security_context {
          fs_group    = 1000
          run_as_user = 1000
        }

      }
    }

    update_strategy {
      rolling_update {
        partition = 0
      }
      type = "RollingUpdate"
    }
  }

  depends_on = [kubernetes_service.keycloak_service, kubernetes_service.keycloak_discovery]
}

resource "kubernetes_ingress_v1" "keycloak_ingress" {
  metadata {
    name      = "keycloak-ingress"
    namespace = var.namespace
    labels = {
      app       = "keycloak"
      component = "ingress"
    }
    annotations = {
      "nginx.ingress.kubernetes.io/proxy-ssl-verify" : "on"
      "nginx.ingress.kubernetes.io/proxy-ssl-secret" : "keycloak/keycloak-tls"
      "nginx.ingress.kubernetes.io/proxy-ssl-name" : "keycloak-cluster-service.keycloak.svc.cluster.local"
      "nginx.ingress.kubernetes.io/backend-protocol" : "HTTPS"
      "nginx.ingress.kubernetes.io/rewrite-target" : "/"
      "nginx.ingress.kubernetes.io/proxy-body-size" : 0
    }
  }

  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = ["${var.host_name}.${var.cloud_domain}"]
      secret_name = "keycloak-ingress-tls"
    }
    rule {
      host = "${var.host_name}.${var.cloud_domain}"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "keycloak-cluster-service"
              port {
                name = "https"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_stateful_set.keycloak_cluster]
}
