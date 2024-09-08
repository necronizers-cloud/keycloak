data "kubernetes_secret" "keycloak_database_credentials" {
  metadata {
    name      = var.keycloak_database_credentials_name
    namespace = var.postgres_namespace
  }
}

resource "kubernetes_secret" "keycloak_database_credentials" {
  metadata {
    name      = var.keycloak_database_credentials_name
    namespace = var.namespace

    labels = {
      app       = "keycloak"
      component = "secret"
    }
  }

  data = {
    "username" = data.kubernetes_secret.keycloak_database_credentials.data["username"]
    "password" = data.kubernetes_secret.keycloak_database_credentials.data["password"]
  }

  type = "kubernetes.io/basic-auth"
}
