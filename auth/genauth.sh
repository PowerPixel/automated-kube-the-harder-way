#!/usr/bin/env bash

set -xe
dir=$(dirname "$0")


gencert() {
  name=$1
  cfssl gencert \
    -ca="$dir/ca.pem" \
    -ca-key="$dir/ca-key.pem" \
    -config="$dir/ca-config.json" \
    -profile=kubernetes \
    "$dir/$name-csr.json" | cfssljson -bare $name
}

cfssl gencert -initca "$dir/ca-csr.json" | cfssljson -bare ca
source "${dir}/generate-csr-nodes.sh"

for name in kubernetes admin kube-scheduler kube-controller-manager kube-proxy service-account; do
  gencert $name
done

for i in $(seq 0 2); do
  gencert control$i
  gencert worker$i
done

rm -rf "$dir/*.csr"

source "${dir}/generate-kubeconfigs.sh"
source "${dir}/gen-enc-key.sh"