#!/bin/bash

set -e

# helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
# helm repo update

helm upgrade --install my-pihole mojo2600/pihole \
  --version 2.29.1 \
  --namespace pihole \
  --create-namespace \
  --values - <<EOF


adminPassword: "changeme"

podDnsConfig:
  enabled: true
  policy: "None"
  nameservers:
  - 127.0.0.1
  - 9.9.9.9

dnsmasq:
  # -- Load custom user configuration files from /etc/dnsmasq.d
  enableCustomDnsMasq: true

  customDnsEntries:
    - address=/kubesoar.test/192.168.2.100
    - address=/gateway.test/192.168.2.101

persistentVolumeClaim:
  enabled: true

serviceDhcp:
  enabled: false

ingress:
  enabled: false
  ingressClassName: nginx
  annotations:
    cert-manager.io/cluster-issuer: self-signed-issuer
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
  hosts:
    - pihole.kubsoar.test
  tls:
    - hosts:
        - pihole.kubsoar.test
      secretName: pihole-tls

serviceWeb:
  loadBalancerIP: 192.168.2.118
  mixedService: true
  type: LoadBalancer
  https:
    enabled: false
  annotations:
    metallb.universe.tf/allow-shared-ip: pihole-svc

serviceDns:
  mixedService: true
  type: LoadBalancer
  loadBalancerIP: 192.168.2.118
  annotations:
    metallb.universe.tf/allow-shared-ip: pihole-svc

EOF
