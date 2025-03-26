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


dnsmasq:
  # -- Load custom user configuration files from /etc/dnsmasq.d
  enableCustomDnsMasq: true

  customDnsEntries:
    - address=/foo.bar/192.168.2.119

persistentVolumeClaim:
  enabled: true

serviceDhcp:
  enabled: false

ingress:
  enabled: false
  ingressClassName: nginx
  annotations:
    cert-manager.io/cluster-issuer: self-signed-issuer
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
