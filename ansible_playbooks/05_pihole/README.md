


# Script for pihole vm


```

#!/usr/bin/env bash
set -e

echo "📦 Installing Podman and Podman-Docker..."
sudo dnf install -y podman podman-docker

echo "🔌 Enabling Podman services..."
sudo systemctl enable --now podman.socket
sudo systemctl enable --now podman-restart.service

echo "🛑 Disabling systemd-resolved to free up port 53..."
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

echo "🔧 Setting static DNS resolver..."
sudo rm -f /etc/resolv.conf
echo "nameserver 9.9.9.9" | sudo tee /etc/resolv.conf > /dev/null

echo "🛠 Preventing NetworkManager from re-enabling resolved..."
sudo mkdir -p /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/conf.d/no-resolved.conf > /dev/null <<EOF
[main]
dns=default
EOF

echo "🔄 Restarting NetworkManager..."
sudo systemctl restart NetworkManager

echo "📂 Creating /home/jwhiteaker/etc-dnsmasq.d for custom DNS configs..."
sudo mkdir -p /home/jwhiteaker/etc-dnsmasq.d
sudo chown 1000:1000 /home/jwhiteaker/etc-dnsmasq.d
sudo chmod 755 /home/jwhiteaker/etc-dnsmasq.d

echo "🚀 Running Pi-hole container with host networking..."
sudo podman run -d \
  --name pihole \
  --network host \
  --privileged \
  -e TZ='America/New_York' \
  -e FTLCONF_webserver_api_password='your-password' \
  -e FTLCONF_dns_listeningMode='all' \
  -e FTLCONF_misc_etc_dnsmasq_d='true' \
  -v pihole:/etc/pihole:Z \
  -v /home/jwhiteaker/etc-dnsmasq.d:/etc/dnsmasq.d:Z \
  --restart=unless-stopped \
  docker.io/pihole/pihole:latest

echo "✅ Pi-hole installed and running!"
echo "🌐 Access it via http://<your-host-IP>/admin"
```
