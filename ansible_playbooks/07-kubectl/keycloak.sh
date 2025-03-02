#! /bin/bash



# kubectl delete -f https://operatorhub.io/install/keycloak-operator.yaml

# kubectl wait --for=condition=available deployment/my-keycloak-operator-controller-manager -n my-keycloak-operator --timeout=300s

# kubectl apply -f - <<EOF
# apiVersion: k8s.keycloak.org/v2alpha1
# kind: Keycloak
# metadata:
#   name: example-keycloak
#   namespace: my-keycloak-operator
#   labels:
#     app: sso
# spec:
#   instances: 1
#   hostname:
#     hostname: keycloak.k3s.homelab.kubesoar.com
#   http:
#     httpEnabled: true


#   networkPolicy:
#     enabled: false
# EOF





CUSTOM_DOMAIN="k3s.homelab.kubesoar.com"


helm upgrade --install my-keycloak bitnami/keycloak --version 24.4.11 --wait --timeout 15m \
  --namespace keycloak --create-namespace --values - <<EOF
auth:
  createAdminUser: true
  adminUser: admin
  adminPassword: admin
  managementUser: manager
  managementPassword: manager



ingress:
  ingressClassName: traefik
  enabled: true
  hostnameStrict: false
  hostname: keycloak.homelab.kubesoar.com

  annotations:
    kubernetes.io/ingress.class: traefik
    cert-manager.io/cluster-issuer: ca-issuer

  tls: true
  selfSigned: true
  secretName: ${CUSTOM_DOMAIN}-tls-secret

proxy: edge


proxyHeaders: "xforwarded"

networkPolicy:
  enabled: false

httpRelativePath: "/"

replicaCount: 1

postgresql:
  enabled: true
  auth:
    postgresPassword: "JoeMontana11#"
    username: keycloak
    password: "JoeMontana11#"
    database: keycloak
  architecture: standalone
EOF
