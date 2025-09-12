#!/bin/bash
set -e  # エラー時に停止

cd $(dirname $0)

USERNAME=$(oc whoami)
PROJECT_NAME="coolstore-${USERNAME}"
APP_NAME=coolstore-quarkus

echo "======================================"
echo "🚀 03-DEPLOY: Starting deployment for user: ${USERNAME}"
echo "📂 Project: ${PROJECT_NAME}"
echo "🏷️  Application: ${APP_NAME}"
echo "======================================"

# Switch to the correct project
echo "Switching to project: ${PROJECT_NAME}"
oc project ${PROJECT_NAME}

# Create or update application
echo "Creating/updating application..."
oc new-app ${APP_NAME} --dry-run -o yaml | oc apply -f -

# Set environment variables from postgres-creds secret
echo "Setting database environment variables..."
oc set env --from=secret/postgres-creds deployment/${APP_NAME}

# Create HTTPS route (edge termination for security)
echo "Creating secure route..."
oc create route edge ${APP_NAME} \
  --service=${APP_NAME} \
  --port=8080-tcp \
  --dry-run -o yaml | oc apply -f -

echo "======================================"
echo "Deployment completed successfully!"
echo "======================================"
echo "Deployment Summary:"
echo "   User: ${USERNAME}"
echo "   Project: ${PROJECT_NAME}"
echo "   Application: ${APP_NAME}"
echo "   PostgreSQL Cluster: postgres"
echo "   Database Service: postgres-rw"ß
echo ""
echo "Application URL:"
ROUTE_URL=$(oc get route ${APP_NAME} -o jsonpath='{.spec.host}' 2>/dev/null || echo "Route not ready yet")
if [ "$ROUTE_URL" != "Route not ready yet" ]; then
    echo "   https://${ROUTE_URL}"
else
    echo "   Route is being created..."
    echo "   Run: oc get route ${APP_NAME} to check status"
fi
echo ""
echo "Useful commands:"
echo "   oc project ${PROJECT_NAME}  # Switch to your project"
echo "   oc get all                  # View all resources"
echo "   oc get cluster              # View PostgreSQL clusters"
echo "   oc logs deployment/${APP_NAME} -f  # View application logs"
echo "======================================" 