#!/bin/bash -e

echo "Setting up namespace for deployment of Keycloak Cluster..."
kubectl apply -f namespace.yml

echo "Fetching Database Credentials..."
DATABASE_CREDS_JSON=$(kubectl get secret -n photoatom-postgres-database  photoatom-postgres-keycloak-creds -o json)

echo "Adding Database Credentials into manifest..."
DATABASE_USERNAME=$(echo "$DATABASE_CREDS_JSON" | jq -rc '.data.username')
DATABASE_PASSWORD=$(echo "$DATABASE_CREDS_JSON" | jq -rc '.data.password')

sed -i "s|DATABASE_USERNAME|$DATABASE_USERNAME|g" database-secret.yml
sed -i "s|DATABASE_PASSWORD|$DATABASE_PASSWORD|g" database-secret.yml

echo "Setting up Database Credentials..."
kubectl apply -f database-secret.yml

echo "Fetching PostgreSQL Client Certificates..."
CA_JSON=$(kubectl get secret -n photoatom-postgres-database postgres-ca -o json)
CERT_JSON=$(kubectl get secret -n photoatom-postgres-database photoatom-keycloak-client-certs -o json)

echo "Adding Certificate Authority Details into manifest..."
CA_CRT=$(echo "$CA_JSON" | jq -rc '.data."ca.crt"')
TLS_CRT=$(echo "$CERT_JSON" | jq -rc '.data."tls.crt"')
TLS_KEY=$(echo "$CERT_JSON" | jq -rc '.data."tls.key"')

sed -i "s|CA_CERT_HERE|$CA_CRT|g" database-cert.yml
sed -i "s|TLS_CERT_HERE|$TLS_CRT|g" database-cert.yml
sed -i "s|TLS_KEY_HERE|$TLS_KEY|g" database-cert.yml

echo "Setting up PostgreSQL Client Certificates..."
kubectl apply -f database-cert.yml