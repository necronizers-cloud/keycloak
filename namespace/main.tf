// Namespace for Keycloak Cluster
resource "kubernetes_namespace" "keycloak" {
  metadata {
    name = var.namespace
    labels = {
      app       = "keycloak"
      component = "namespace"
    }
  }
}

resource "null_resource" "install_crds" {
  triggers = {
    "install_crds" : true
  }

  provisioner "local-exec" {
    command = <<EOT
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.4/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.4/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.4/kubernetes/kubernetes.yml -n ${var.namespace}
sleep 60
    EOT
  }

  depends_on = [kubernetes_namespace.keycloak]
}
