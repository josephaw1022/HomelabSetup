#!/bin/bash

set -e

echo "Installing Podman and Podman-Docker..."
sudo dnf -y install podman podman-docker

echo "Enabling Podman services..."
sudo systemctl enable --now podman.socket
sudo systemctl enable --now podman-restart.service

echo "Creating nginx.conf..."
cat <<EOF > ./nginx.conf
events {}

stream {
  upstream k3s_servers {
    server 192.168.122.24;
  }

  server {
    listen 6443;
    proxy_pass k3s_servers;
  }
}
EOF

echo "Running nginx container with custom config..."
podman run -d --name nginx --restart always \
  -v ./nginx.conf:/etc/nginx/nginx.conf:Z \
  -p 6443:6443 \
  nginx:stable


echo "Done! Nginx is running and forwarding port 6443."
