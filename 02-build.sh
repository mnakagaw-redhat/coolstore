#!/bin/bash
set -e  # エラー時に停止

cd $(dirname $0)

USERNAME=$(oc whoami)
PROJECT_NAME="${USERNAME}-wk"
APP_NAME=coolstore-quarkus

echo "======================================"
echo "🔨 02-BUILD: Starting build for user: ${USERNAME}"
echo "📂 Project: ${PROJECT_NAME}"
echo "🏷️  Application: ${APP_NAME}"
echo "======================================"

# Switch to the correct project
echo "Switching to project: ${PROJECT_NAME}"
oc project ${PROJECT_NAME}

# Build application as uber-jar
echo "Building application with Maven..."
mvn clean package -DskipTests=true -Dquarkus.package.type=uber-jar

# Get the built jar file (more specific pattern for uber-jar)
JAR=$(ls -1 target/*-runner.jar)
echo "Using JAR: $JAR"

# Start OpenShift build
echo "Starting OpenShift build..."
oc start-build ${APP_NAME} --from-file=$JAR --follow

echo "✅ Build completed successfully!"
