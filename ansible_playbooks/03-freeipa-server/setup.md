


modify etc/hosts with 

```bash
<ip of server> <hostname>
```

example

```
192.168.6.32 freeipa.kubesoar.com
```

# then run this podman command 

```bash

sudo podman run -d \
  --name freeipa-server \
  --restart=always \
  --network=host \
  --add-host freeipa.kubesoar.com:192.168.7.38 \
  -v freeipa-data:/data \
  -v freeipa-config:/config \
  -h freeipa.kubesoar.com \
  docker.io/freeipa/freeipa-server:fedora-41 \
  ipa-server-install \
  --realm KUBESOAR.COM \
  --domain kubesoar.com \
  --ds-password "freeipa" \
  --admin-password "freeipa" \
  --hostname freeipa.kubesoar.com \
  --unattended

```



## also got this working too 

```
#!/bin/bash

# Configuration
CONTAINER_NAME="idm-server"
IMAGE="docker.io/freeipa/freeipa-server:fedora-41"
IP="192.168.2.51"
NETWORK_NAME="homelabnetwork"
REALM="KUBESOAR.COM"
DOMAIN="kubesoar.com"
DATA_VOL="idm-data"
CONFIG_VOL="idm-config"
LOGS_VOL="idm-logs"

# Cleanup
podman rm -f "$CONTAINER_NAME"
podman volume rm -f "$DATA_VOL" "$CONFIG_VOL" "$LOGS_VOL"

# Create volumes
podman volume create "$DATA_VOL"
podman volume create "$CONFIG_VOL"
podman volume create "$LOGS_VOL"

# Run container
sudo podman run -d \
  --replace \
  --name "$CONTAINER_NAME" \
  --restart=always \
  --network "$NETWORK_NAME" \
  --ip "$IP" \
  -v "$DATA_VOL":/data:Z \
  -v "$CONFIG_VOL":/config:Z \
  -v "$LOGS_VOL":/var/log:Z \
  -e IPA_SERVER_HOSTNAME="idm.kubesoar.com" \
  "$IMAGE" \
  ipa-server-install \
    --realm "$REALM" \
    --domain "$DOMAIN" \
    --ds-password "FreeIPApass123!" \
    --admin-password "FreeIPApass123!" \
    --unattended \
    --no-ntp



```
