variable "namespace" {
  default     = "keycloak"
  description = "Namespace to be used for deploying Keycloak Cluster and related resources."
}

variable "postgres_namespace" {
  default     = "postgres"
  description = "Namespace to be used for deploying Postgres Cluster and related resources."
}

variable "keycloak_database_credentials_name" {
  default     = "keycloak-database-credentials"
  description = "Database Credentials Secret Name for Keycloak"
}
