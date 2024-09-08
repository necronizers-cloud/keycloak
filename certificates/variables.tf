variable "namespace" {
  default     = "keycloak"
  description = "Namespace to be used for deploying Keycloak Cluster and related resources."
}

variable "cluster_issuer_name" {
  default     = "photoatom-issuer"
  description = "Name for the Cluster Issuer"
}

variable "keycloak_ca_name" {
  default     = "keycloak-ca-certificate"
  description = "Name for the Certificate Authority for Keycloak Cluster"
}

variable "keycloak_issuer_name" {
  default     = "keycloak-ca-issuer"
  description = "Name for the Issuer for Keycloak Cluster"
}

variable "keycloak_certificate_name" {
  default     = "keycloak-certificate"
  description = "Name for the certificate for Keycloak Cluster"
}
