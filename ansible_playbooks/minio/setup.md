

```bash 
#!/bin/bash

# Configurable variables
CONTAINER_NAME="minio"
IMAGE="docker.io/minio/minio:latest"
VOLUME_NAME="minio-data"
ROOT_USER="root"
ROOT_PASSWORD="Minio213034#"
DEFAULT_BUCKETS="homelab"
NETWORK_NAME="homelabnetwork"
PARENT_INTERFACE="enp0s25"
STATIC_IP="192.168.2.50"

# Ensure netavark DHCP proxy is running
sudo systemctl enable --now netavark-dhcp-proxy.socket

# Create macvlan network if it doesn't exist
if ! podman network exists "$NETWORK_NAME"; then
  echo "Creating network: $NETWORK_NAME"
  podman network create -d macvlan \
    -o parent="$PARENT_INTERFACE" \
    --subnet=192.168.2.0/24 \
    --gateway=192.168.2.1 \
    "$NETWORK_NAME"
fi

# Create volume if it doesn't exist
if ! podman volume exists "$VOLUME_NAME"; then
  echo "Creating volume: $VOLUME_NAME"
  podman volume create "$VOLUME_NAME"
fi

# Check if container exists
if podman container exists "$CONTAINER_NAME"; then
  echo "Container '$CONTAINER_NAME' already exists."

  # Check if it's running
  if podman inspect -f '{{.State.Running}}' "$CONTAINER_NAME" | grep -q true; then
    echo "Container is already running."
  else
    echo "Starting existing container..."
    podman start "$CONTAINER_NAME"
  fi

  exit 0
fi

# Run the MinIO container
echo "Creating and starting MinIO container..."
podman run -d \
  --name "$CONTAINER_NAME" \
  --restart=always \
  --network "$NETWORK_NAME" \
  --ip "$STATIC_IP" \
  -v "$VOLUME_NAME":/data \
  -e MINIO_ROOT_USER="$ROOT_USER" \
  -e MINIO_ROOT_PASSWORD="$ROOT_PASSWORD" \
  -e MINIO_DEFAULT_BUCKETS="$DEFAULT_BUCKETS" \
  "$IMAGE" server \
    --address "0.0.0.0:9000" \
    --console-address "0.0.0.0:80" \
    /data
```


