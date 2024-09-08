resource "kubernetes_manifest" "keycloak" {
  manifest = {
    "apiVersion" = "k8s.keycloak.org/v2alpha1"
    "kind"       = "Keycloak"
    "metadata" = {
      "labels" = {
        "app"       = "keycloak"
        "component" = "cluster"
      }
      "name"      = var.cluster_name
      "namespace" = var.namespace
    }
    "spec" = {
      "db" = {
        "database" = "keycloak"
        "host"     = "${var.postgres_cluster_name}-rw.${var.postgres_namespace}.svc"
        "passwordSecret" = {
          "key"  = "password"
          "name" = var.keycloak_database_credentials_name
        }
        "poolInitialSize" = 1
        "poolMaxSize"     = 3
        "poolMinSize"     = 2
        "port"            = 5432
        "usernameSecret" = {
          "key"  = "username"
          "name" = var.keycloak_database_credentials_name
        }
        "vendor" = "postgres"
      }
      "hostname" = {
        "hostname" = var.host_name
      }
      "http" = {
        "tlsSecret" = "keycloak-tls"
      }
      "ingress" = {
        "enabled" = false
      }
      "instances" = 3
      "resources" = {
        "limits" = {
          "cpu"    = "500m"
          "memory" = "1Gi"
        }
        "requests" = {
          "cpu"    = "500m"
          "memory" = "1Gi"
        }
      }
      "unsupported" = {
        "podTemplate" = {
          "spec" = {
            "securityContext" = {
              "fsGroup"   = 1000
              "runAsUser" = 1000
            }
          }
        }
      }
    }
  }
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
      "cert-manager.io/cluster-issuer" : "${var.cluster_issuer_name}"
      "nginx.ingress.kubernetes.io/proxy-ssl-verify" : "off"
      "nginx.ingress.kubernetes.io/backend-protocol" : "HTTPS"
      "nginx.ingress.kubernetes.io/rewrite-target" : "/"
      "nginx.ingress.kubernetes.io/proxy-body-size" : 0
    }
  }

  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.host_name]
      secret_name = "keycloak-ingress-tls"
    }
    rule {
      host = var.host_name
      http {
        path {
          path = "/"
          backend {
            service {
              name = "keycloak-cluster-service"
              port {
                number = 8443
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.keycloak]
}
