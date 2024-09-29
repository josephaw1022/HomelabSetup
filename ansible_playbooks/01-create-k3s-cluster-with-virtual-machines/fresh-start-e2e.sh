#!/bin/bash


# run the ./delete-kubeconfig-file.sh script
./delete-kubeconfig-file.sh

ansible-playbook -i inventory.ini playbooks/00-uninstall-k3s.yaml

ansible-playbook -i inventory.ini playbooks/01-initialize-master-node.yaml

ansible-playbook -i inventory.ini playbooks/02-show-kubeconfig.yaml

ansible-playbook -i inventory.ini playbooks/03-initialize-worker-nodes.yaml 


./format-kube-config-file-with-correct-host.sh
