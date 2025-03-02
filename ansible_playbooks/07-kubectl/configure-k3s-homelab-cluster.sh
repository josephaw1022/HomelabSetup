#! /bin/bash


# # Install OLM
# # curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.31.0/install.sh | bash -s v0.31.0


# Helm repos
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add metallb https://metallb.github.io/metallb
helm repo add kubescape https://kubescape.github.io/helm-charts
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo add policy-reporter https://kyverno.github.io/policy-reporter
helm repo add k3k https://rancher.github.io/k3k
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add longhorn https://charts.longhorn.io
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx





# Install metallb
helm upgrade --install \
  metallb oci://registry.suse.com/edge/metallb-chart \
  --namespace metallb-system \
  --create-namespace

while ! kubectl wait --for condition=ready -n metallb-system $(kubectl get\
 pods -n metallb-system -l app.kubernetes.io/component=controller -o name)\
 --timeout=10s; do
 sleep 2
done


# Install Kube Prometheus Stack
helm upgrade --wait --install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

# Install cert manager
helm upgrade --wait --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.16.2 --set crds.enabled=true


# Install kyverno
kubectl apply -f https://github.com/kyverno/kyverno/releases/download/v1.13.0/install.yaml


# Install k3k
helm install --namespace k3k-system --create-namespace k3k k3k/k3k --devel


# Install longhorn
helm upgrade --install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.8.0


# Install the metallb l2 announcement and ip range
kubectl apply -f ./manifests/ip-pool.yaml



# Create the root CA secret
cp ~/.ssl/root-ca/root-ca.pem /tmp/root-ca.pem
cp ~/.ssl/root-ca/root-ca-key.pem /tmp/root-ca-key.pem

kubectl create secret tls -n cert-manager root-ca --cert="/tmp/root-ca.pem" --key="/tmp/root-ca-key.pem"

# Create the cluster issuer
kubectl apply -n cert-manager -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
spec:
  ca:
    secretName: root-ca
EOF


# Create the certificate

# Define the custom domain
CUSTOM_DOMAIN="k3s.homelab.kubesoar.com"



# Create a certificate for the nginx ingress controller
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${CUSTOM_DOMAIN}-cert
  namespace: cert-manager
spec:
  secretName: ${CUSTOM_DOMAIN}-tls-secret
  commonName: "*.${CUSTOM_DOMAIN}"
  dnsNames:
    - "${CUSTOM_DOMAIN}"
    - "*.${CUSTOM_DOMAIN}"
  issuerRef:
    name: ca-issuer
    kind: ClusterIssuer
EOF






# Install tekton
kubectl create -f https://operatorhub.io/install/tektoncd-operator.yaml


kubectl wait --for=condition=available deployment/tekton-operator -n tekton-pipelines --timeout=300s

kubectl apply -f - <<EOF
---
apiVersion: v1
kind: Namespace
metadata:
  name: tekton-pipelines
  annotations:
    argocd.argoproj.io/sync-wave: "2"
---
apiVersion: operator.tekton.dev/v1alpha1
kind: TektonConfig
metadata:
  name: config
  namespace: tekton-pipelines
spec:
  profile: all
  targetNamespace: tekton-pipelines
  pruner:
    resources:
      - pipelinerun
      - taskrun
    keep: 100
    schedule: "0 8 * * *"
  pipeline:
    enable-tekton-oci-bundles: true
  dashboard:
    readonly: false
EOF







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

adminIngress:
  ingressClassName: traefik
  enabled: true
  hostnameStrict: false
  hostname: admin-keycloak.homelab.kubesoar.com

  annotations:
    kubernetes.io/ingress.class: traefik

  tls: true
  selfSigned: true
  secretName: ${CUSTOM_DOMAIN}-admin-tls-secret

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
