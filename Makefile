deploy: base_setup
	@echo "Deployment for Keycloak Cluster"
	@cd src && ./automate.sh
base_setup:
	@echo "Base Setup for Keycloak Cluster"
	@cd base && ./automate.sh