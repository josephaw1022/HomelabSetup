
# Homelab Repository (Under Development)

Welcome to my Homelab repository! This repo is currently **under development**, and the structure described here represents the intended design, **not the current implementation**. Not much is implemented yet, and the goal is to experiment with this structure to see how well it works.

## Repository Structure (Planned)

### 1. `ansible_playbooks/`
This directory will contain Ansible playbooks used for tasks that must be performed imperatively. These playbooks will handle operations that cannot be defined declaratively, such as one-off system configurations or provisioning tasks that require real-time decision-making.

### 2. `charts/`
The `charts/` directory is planned to house all declarative configurations using Helm charts. The directory will be organized to support modular and scalable cluster management.

#### Planned Subdirectories:

- **`clusters/`**
    - Each homelab cluster will have its own Helm chart defined here. The **goal** is to have only **one Helm chart** installed per cluster, which will pull in the necessary resources from other directories.

- **`catalog/`**
    - This directory will contain reusable Helm charts for individual services, applications, or infrastructure components. These charts will be referenced by the cluster Helm charts in the `clusters/` directory.

### 3. Future Expansion
Additional directories and components will be added over time as needed.

---

### Important Notes:
- **This structure is experimental**: The idea is to try this one-Helm-chart-per-cluster model and evaluate its effectiveness.
- **Nothing is currently implemented**: The repo is a work in progress, and this structure is the **intended goal**, not the current state.

---

### Getting Started

1. **Ansible Playbooks (Planned)**:
   - The goal is to use Ansible playbooks for imperative tasks.
  
2. **Helm Charts (Planned)**:
   - Helm charts will be used to manage clusters, with each cluster using a single Helm chart that references reusable components from the `catalog/`.
