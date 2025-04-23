#!/bin/bash

set -e

# === Parse Arguments ===
MASTER_NODES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --master-nodes)
      shift
      while [[ $# -gt 0 && "$1" != --* ]]; do
        MASTER_NODES+=("$1")
        shift
      done
      ;;
    *)
      echo "❌ Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ ${#MASTER_NODES[@]} -eq 0 ]]; then
  echo "❌ No master node IPs provided. Usage: ./setup.sh --master-nodes <ip1> <ip2> ..."
  exit 1
fi

echo "Installing Podman and Podman-Docker..."
sudo dnf -y install podman podman-docker

echo "Enabling Podman services..."
sudo systemctl enable --now podman.socket
sudo systemctl enable --now podman-restart.service

echo "Creating nginx.conf..."
{
  echo "events {}"
  echo
  echo "stream {"
  echo "  upstream k3s_servers {"
  for i in "${!MASTER_NODES[@]}"; do
    echo "    server ${MASTER_NODES[$i]}:6443;"
  done
  echo "  }"
  echo
  echo "  server {"
  echo "    listen 6443;"
  echo "    proxy_pass k3s_servers;"
  echo "  }"
  echo "}"
} > ./nginx.conf

echo "Running nginx container with custom config..."
podman rm -f nginx >/dev/null 2>&1 || true
podman run -d --name nginx --restart always \
  -v ./nginx.conf:/etc/nginx/nginx.conf:Z \
  -p 6443:6443 \
  nginx:stable

echo "✅ Done! Nginx is running and forwarding port 6443 to: ${MASTER_NODES[*]}"
