#! /bin/bash


# Install OLM
curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.31.0/install.sh | bash -s v0.31.0


# Install Operators
kubectl create -f https://operatorhub.io/install/tektoncd-operator.yaml 
kubectl create -f https://operatorhub.io/install/shipwright-operator.yaml
