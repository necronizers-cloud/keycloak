variable "namespace" {
  default     = "keycloak"
  description = "Namespace to be used for deploying Keycloak Cluster and related resources."
}

variable "cluster_issuer_name" {
  default     = "photoatom-issuer"
  description = "Name for the Cluster Issuer"
}

variable "cluster_name" {
  default     = "keycloak-cluster"
  description = "Name for the Keycloak Cluster Name"
}

variable "postgres_cluster_name" {
  default     = "postgresql-cluster"
  description = "Name for the PostgreSQL Cluster Name"
}

variable "keycloak_database_credentials_name" {
  default     = "keycloak-database-credentials"
  description = "Database Credentials Secret Name for Keycloak"
}

variable "postgres_namespace" {
  default     = "postgres"
  description = "Namespace to be used for deploying Postgres Cluster and related resources."
}

variable "host_name" {
  default     = "auth.photoatom.local"
  description = "Host name to be used with Keycloak Cluster Ingress"
}
