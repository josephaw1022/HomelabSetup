#!/bin/bash

# This script formats the kube config file with the correct host IP address.

# Grab the host IP from the ansible_host value in the inventory file from the line that looks like this:
# master1 ansible_host=172.20.12.11 ansible_user=jwhiteaker ansible_password=joerod111 ansible_become=yes ansible_become_method=sudo ansible_become_pass=joerod111

# The file name is inventory.ini

# Get the first IP address of the master node from the inventory file
master1_ip=$(grep -m 1 'master1' inventory.ini | awk -F'ansible_host=' '{print $2}' | awk '{print $1}')

# Check if IP address was extracted
if [ -z "$master1_ip" ]; then
  echo "Error: Could not extract master1 IP address from inventory.ini"
  exit 1
fi

echo "Master1 IP address is: $master1_ip"

# The kubeconfig file name is k3s-kubeconfig.yaml
kubeconfig_file="k3s-kubeconfig.yaml"

# Check if the kubeconfig file exists
if [ ! -f "$kubeconfig_file" ]; then
  echo "Error: $kubeconfig_file not found!"
  exit 1
fi

# Escape any special characters in the IP address (if any)
escaped_ip=$(echo "$master1_ip" | sed -e 's/[\/&]/\\&/g')

# Replace 127.0.0.1 with the extracted master1 IP address in the kubeconfig file
sed -i "s/127.0.0.1/$escaped_ip/g" "$kubeconfig_file"

echo "Updated $kubeconfig_file with master1 IP address: $master1_ip"

