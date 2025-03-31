#! /bin/bash

CUSTOM_DOMAIN="keycloak.kubesoar.test"


helm upgrade --install keycloak bitnami/keycloak --version 24.4.11 --wait --timeout 15m \
  --namespace keycloak --create-namespace --values - <<EOF
auth:
  createAdminUser: true
  adminUser: admin
  adminPassword: admin
  managementUser: manager
  managementPassword: manager



ingress:
  ingressClassName: nginx
  enabled: true
  hostnameStrict: false
  hostname: keycloak.kubesoar.test

  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: self-signed-issuer

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
  enabled: false


externalDatabase:
  host: laptop-server.kubesoar.com
  port: 5432
  user: k3s
  password: k3s
  database: keycloak


EOF
