# FreeIPA Server and Certificate Setup Guide

This guide outlines the steps to set up your FreeIPA server, configure the necessary DNS records using a Pi-hole server, and extract the required CA certificates to ensure secure access to the FreeIPA web UI.

---

## Prerequisites

1. **Pi-hole Server Setup on Fedora VM**  
   - Ensure you have a Pi-hole server running on a Fedora VM.
   - In the Pi-hole server, create an A-record for your FreeIPA server in the local dns page of pihole. For example, if your FreeIPA server’s domain is `freeipa.homelab.kubesoar.com`, point this record to the FreeIPA server’s IP address.
   - Next, create a PTR (reverse) record in the Pi-hole server. This record should map the FreeIPA server’s IP (in reverse notation) back to `freeipa.homelab.kubesoar.com`.

2. **Docker Compose Structure**  
   SSH into your Pi-hole server to verify your Docker Compose setup. Your directory should be structured similar to:

   ```bash
   ├── docker-compose.yaml
   ├── etc-dnsmasq.d
   │   └── 01-pihole.conf
   └── etc-pihole
   ```

   In the `01-pihole.conf` file, include the following configuration:

   ```conf
   local=/homelab.kubesoar.com/
   address=/homelab.kubesoar.com/<ip>

   ptr-record=<ip-backward>.in-addr.arpa,"freeipa.homelab.kubesoar.com"
   ```

---

## FreeIPA Server Installation

1. **Run the Playbook**  
   Execute the `create-freeipa-server.yml` playbook to deploy your FreeIPA server on the host network.  
   - **Note:** Before running the playbook, ensure that you have created your inventory file and updated the required variables accordingly.

---

## FreeIPA Server Installation and Certificate Extraction Guide

### Step 1. Install the FreeIPA Server

- Use the provided playbook to install the FreeIPA server on your preferred host (physical server or VM).  
- The playbook launches the FreeIPA container on the host network.

### Step 2. Extract the Root CA Certificates

On the VM, create a directory to store your certificates and copy the necessary files from the FreeIPA container:

```bash
mkdir -p ~/freeipa-certs
podman cp freeipa-server:/root/ca-agent.p12 ~/freeipa-certs/
podman cp freeipa-server:/root/cacert.p12 ~/freeipa-certs/
```

### Step 3. Download Certificates via Cockpit

- Open Cockpit and navigate to the FreeIPA server’s file interface.
- Download the `cacert.p12` and `ca-agent.p12` files from the VM host to your local machine.

### Step 4. Extract the CA Certificate

Use OpenSSL to extract the CA certificate from the `cacert.p12` file:

```bash
openssl pkcs12 -in cacert.p12 -clcerts -nokeys -out ca.crt
```

- **Tip:** When prompted, enter the admin password specified in the playbook. If the extraction is successful, the certificate information will be displayed in your terminal.

### Step 5. Add the CA Certificate to Your Trusted Store

To avoid certificate errors when accessing the FreeIPA web UI, add the extracted CA certificate to your system’s trusted certificates:

```bash
sudo cp ca.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
```
