cd $(dirname $0)

APP_NAME=coolstore-quarkus
export AUTH_SERVER_URL=https://keycloak-ingress-keycloak.apps.rosa.rhsc2025.c4cn.p3.openshiftapps.com
export AUTH_REALM=eap
export AUTH_RESOURCE=eap-app

# mvn clean package -DskipTests=true
mvn clean package -DskipTests=true -Dquarkus.package.type=uber-jar
JAR=$(ls -1 target/*.jar)

# Create keycloak.json from template
envsubst < keycloak.template.json > src/main/resources/META-INF/resources/keycloak.json

oc new-build registry.access.redhat.com/ubi8/openjdk-21 --strategy source --binary --name ${APP_NAME} --dry-run -o yaml | oc apply -f -
oc start-build ${APP_NAME} --from-file=$JAR --follow
oc new-app ${APP_NAME}

oc expose service ${APP_NAME}
oc create route edge coolstore-quarkus \
  --service=coolstore-quarkus \
  --port=8080-tcp
