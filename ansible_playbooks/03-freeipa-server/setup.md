


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
sudo podman run -d \
  --replace \
  --name idm-server \
  --restart=always \
  --network homelabnetwork \
  --ip 192.168.2.51 \
  -v idm-data:/data \
  -v idm-config:/config \
  -v ./logs:/var/log:Z \
  -e IPA_SERVER_HOSTNAME=idm.kubesoar.com \
  docker.io/freeipa/freeipa-server:fedora-41 \
  ipa-server-install \
  --realm IDM.KUBESOAR.COM \
  --domain kubesoar.com \
  --ds-password "FreeIPApass123!" \
  --admin-password "FreeIPApass123!" \
  --unattended

```
