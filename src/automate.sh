echo "Setting up Keycloak Certificate CA and sleeping for 10 seconds..."
kubectl apply -f ca.yml
sleep 10

echo "Setting up Keycloak Certificate CA Issuer and sleeping for 10 seconds..."
kubectl apply -f ca-issuer.yml
sleep 10

echo "Setting up Keycloak Instance Certificate and sleeping for 10 seconds..."
kubectl apply -f cert.yml
sleep 10

echo "Setting up Keycloak CRDs..."
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.4/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.4/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml

echo "Setting up Keycloak Operator and sleeping for a minute..."
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/25.0.4/kubernetes/kubernetes.yml -n photoatom-keycloak-auth
sleep 60

echo "Setting up Keycloak Cluster..."
kubectl apply -f keycloak.yml

echo "Setting up Keycloak Ingress..."
kubectl apply -f ingress.yml