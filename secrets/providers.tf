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
  }
}

provider "kubernetes" {

}

provider "null" {

}

provider "random" {

}
