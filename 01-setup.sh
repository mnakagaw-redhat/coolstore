#!/bin/bash
set -e  # エラー時に停止

cd $(dirname $0)

# Get current OpenShift user and create project name
USERNAME=$(oc whoami)
PROJECT_NAME="${USERNAME}-wk"
APP_NAME=coolstore-quarkus

echo "======================================"
echo "🚀 01-SETUP: Starting setup for user: ${USERNAME}"
echo "📂 Project name: ${PROJECT_NAME}"
echo "🏷️  Application name: ${APP_NAME}"
echo "======================================"

# Create or switch to project
echo "Creating/switching to project: ${PROJECT_NAME}"
if oc get project ${PROJECT_NAME} >/dev/null 2>&1; then
    echo "Project ${PROJECT_NAME} already exists. Switching to it..."
    oc project ${PROJECT_NAME}
else
    echo "Creating new project: ${PROJECT_NAME}"
    oc new-project ${PROJECT_NAME} --description="Coolstore application for ${USERNAME}" --display-name="Coolstore-${USERNAME}"
fi

# Keycloak configuration
export AUTH_SERVER_URL=https://keycloak-ingress-keycloak.apps.rosa.rhsc2025.c4cn.p3.openshiftapps.com
export AUTH_REALM=eap
export AUTH_RESOURCE=eap-app

# Create keycloak.json from template
echo "Creating Keycloak configuration..."
sed -e "s|\${AUTH_SERVER_URL}|${AUTH_SERVER_URL}|g" \
    -e "s|\${AUTH_REALM}|${AUTH_REALM}|g" \
    -e "s|\${AUTH_RESOURCE}|${AUTH_RESOURCE}|g" \
    keycloak.template.json > src/main/resources/META-INF/resources/keycloak.json

# Create BuildConfig
echo "Creating BuildConfig..."
oc new-build registry.access.redhat.com/ubi8/openjdk-21 --strategy source --binary --name ${APP_NAME} --dry-run -o yaml | oc apply -f -

# Deploy PostgreSQL database using existing postgresql.yaml
echo "Setting up PostgreSQL database..."
if ! oc get cluster postgres >/dev/null 2>&1; then
    echo "Creating PostgreSQL cluster using deploy/postgresql.yaml"
    oc apply -f deploy/postgresql.yaml
    
    # Wait for PostgreSQL cluster to be ready
    echo "Waiting for PostgreSQL cluster to be ready..."
    oc wait --for=condition=Ready cluster/postgres --timeout=300s
    echo "PostgreSQL cluster is ready"
else
    echo "PostgreSQL cluster 'postgres' already exists"
fi

# Apply postgres credentials
echo "Applying PostgreSQL credentials..."
oc apply -f deploy/postgres-cred.yaml

echo "✅ Setup completed successfully!"