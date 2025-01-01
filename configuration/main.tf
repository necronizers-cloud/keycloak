resource "kubernetes_config_map" "realm_configuration" {
  metadata {
    name      = "cloud-realm-configuration"
    namespace = var.namespace
    labels = {
      app       = "keycloak"
      component = "configmap"
    }
  }

  data = {
    "realm.json" = "${file("${path.module}/photoatom.json")}"
  }
}
