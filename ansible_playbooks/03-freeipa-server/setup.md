


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