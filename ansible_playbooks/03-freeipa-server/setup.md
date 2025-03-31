


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


you then need to run 

```
#!/bin/bash

# Configuration
NETWORK_NAME="homelabnetwork"
PARENT_INTERFACE="enp0s25"
SUBNET="192.168.2.0/24"
GATEWAY="192.168.2.1"
HOST_INTERFACE="macvlan0"
HOST_IP="192.168.2.10"

# Ensure netavark DHCP proxy is active (Podman uses this with macvlan)
sudo systemctl enable --now netavark-dhcp-proxy.socket

# Delete existing macvlan interface if it exists
if ip link show "$HOST_INTERFACE" &>/dev/null; then
  echo "[+] Removing old macvlan interface..."
  sudo ip link delete "$HOST_INTERFACE"
fi

# Create macvlan interface
echo "[+] Creating macvlan interface on host..."
sudo ip link add "$HOST_INTERFACE" link "$PARENT_INTERFACE" type macvlan mode bridge
sudo ip addr add "$HOST_IP/24" dev "$HOST_INTERFACE"
sudo ip link set "$HOST_INTERFACE" up

# Enable routing to allow communication between host and macvlan containers
echo "[+] Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1

# Add static route if needed (optional, depending on network stack)
# sudo ip route add "$SUBNET" dev "$HOST_INTERFACE"

echo "[+] Macvlan interface '$HOST_INTERFACE' is ready. You should now be able to ping containers on $SUBNET from the host."
```

so that you can connect your host machine to that freeipa server. host machines do not have access to macvlan networks by default.