#!/usr/bin/env bash

set -xe

. "$(dirname $0)/auth-vars.sh"

genkubeconfig() {
  cert=$1
  user=$2
  kubeconfig="$dir/${cert}.kubeconfig"

  kubectl config set-cluster kubenet \
    --certificate-authority="$dir/ca.pem" \
    --embed-certs=true \
    --server=https://kubernetes:6443 \
    --kubeconfig="$kubeconfig"

  kubectl config set-credentials "$user" \
    --client-certificate="$dir/${cert}.pem" \
    --client-key="$dir/${cert}-key.pem" \
    --embed-certs=true \
    --kubeconfig="$kubeconfig"

  kubectl config set-context default \
    --cluster=kubenet \
    --user="$user" \
    --kubeconfig="$kubeconfig"

  kubectl config use-context default \
    --kubeconfig="$kubeconfig"
}

genkubeconfig admin admin
genkubeconfig kube-scheduler system:kube-scheduler
genkubeconfig kube-controller-manager system:kube-controller-manager
genkubeconfig kube-proxy system:kube-proxy

for node in ${vmnames[@]}; do
  genkubeconfig $node system:node:$node
done