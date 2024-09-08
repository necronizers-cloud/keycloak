terraform {
  required_providers {
    kubernetes = {
      source  = "opentofu/kubernetes"
      version = "2.32.0"
    }
    null = {
      source  = "opentofu/null"
      version = "3.2.2"
    }
    random = {
      source  = "opentofu/random"
      version = "3.6.2"
    }
  }

  backend "kubernetes" {
    secret_suffix = "secrets.keycloak"
    config_path   = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "null" {

}

provider "random" {

}
