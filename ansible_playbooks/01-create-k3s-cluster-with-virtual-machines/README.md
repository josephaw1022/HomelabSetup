
## K3s Cluster Setup with Ansible

This repository contains Ansible playbooks and a shell script for setting up a K3s Kubernetes cluster, including master and worker nodes. After setting up the cluster, you can use the `k3s-kubeconfig.yaml` file with the Headlamp desktop application for Kubernetes management.

### Directory Structure

```
.
├── format-kube-config-file-with-correct-host.sh  # Script to update kubeconfig file with correct master IP
├── inventory.ini                                # Inventory file for Ansible hosts
├── k3s-kubeconfig.yaml                          # Kubeconfig file for accessing K3s cluster
├── playbooks                                    # Playbooks for setting up K3s cluster
│   ├── 00-uninstall-k3s.yaml                    # Uninstall K3s from nodes
│   ├── 01-initialize-master-node.yaml           # Set up master node
│   ├── 02-show-kubeconfig.yaml                  # Show kubeconfig content after master node setup
│   └── 03-initialize-worker-nodes.yaml          # Set up worker nodes
├── README.md                                    # This README file
└── vars.yaml                                    # Variables for playbooks (like K3s token)
```

---

### Step 1: Decrypt the Inventory File

If your `inventory.ini` file is encrypted, you will need to decrypt it before running the playbooks.

```bash
ansible-vault decrypt inventory.ini
```

Make sure you have the appropriate decryption password for the file.

---

### Step 2: Run the Playbooks

#### 1. Uninstall K3s (if needed)

If you need to start with a fresh setup, you can uninstall K3s from your nodes by running the `00-uninstall-k3s.yaml` playbook:

```bash
ansible-playbook -i inventory.ini playbooks/00-uninstall-k3s.yaml
```

#### 2. Initialize the Master Node

Set up the master node by running the `01-initialize-master-node.yaml` playbook:

```bash
ansible-playbook -i inventory.ini playbooks/01-initialize-master-node.yaml
```

#### 3. View the Kubeconfig File (Optional)

To verify that the `k3s-kubeconfig.yaml` file was created correctly after setting up the master node, you can run the following playbook:

```bash
ansible-playbook -i inventory.ini playbooks/02-show-kubeconfig.yaml
```

#### 4. Initialize the Worker Nodes

Next, set up the worker nodes by running the `03-initialize-worker-nodes.yaml` playbook:

```bash
ansible-playbook -i inventory.ini playbooks/03-initialize-worker-nodes.yaml
```

---

### Step 3: Update the Kubeconfig File with the Correct Master IP

After running the playbooks, you need to update the `k3s-kubeconfig.yaml` file with the correct master node IP address. Use the provided shell script to automate this process.

1. Give the script execution permissions:

   ```bash
   chmod +x format-kube-config-file-with-correct-host.sh
   ```

2. Run the script to update the kubeconfig file:

   ```bash
   ./format-kube-config-file-with-correct-host.sh
   ```

This script will automatically replace `127.0.0.1` with the correct master node IP in the `k3s-kubeconfig.yaml` file.

---

### Step 4: Use the Updated Kubeconfig in Headlamp

Headlamp is a desktop GUI application for managing Kubernetes clusters. To use it with your new K3s cluster:

1. Open Headlamp on your desktop.
2. Import the updated `k3s-kubeconfig.yaml` file by selecting **Add Cluster** and providing the path to the file.
   
   Example path: `/path/to/k3s-kubeconfig.yaml`

Headlamp will now connect to your K3s cluster, and you can manage your nodes and workloads using the GUI.

---

### Notes

- Ensure that you have the correct `token` value in `vars.yaml` to allow worker nodes to join the master.
- Make sure the `inventory.ini` file is properly configured with the correct `ansible_host` values for each node.
