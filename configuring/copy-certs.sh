#!/usr/bin/env bash

set -xe
dir=$(dirname "$0")
authdir="$dir/../auth"

source "$authdir/auth-vars.sh"

for cert in ${commoncerts[@]}; do
    cp $authdir/$cert $dir/roles/install-control-certs/files
    cp $authdir/$cert $dir/roles/install-worker-certs/files
    cp $authdir/$cert $dir/roles/install-client-certs/files
done

for cert in ${workercerts[@]}; do
    cp $authdir/$cert $dir/roles/install-worker-certs/files
done

for node in ${workers[@]}; do 
    cp $authdir/$node.pem $dir/roles/install-worker-certs/files
    cp $authdir/$node-key.pem $dir/roles/install-worker-certs/files
    cp $authdir/$node.kubeconfig $dir/roles/install-worker-certs/files
done

for cert in ${controlcerts[@]}; do
    cp $authdir/$cert $dir/roles/install-control-certs/files
done

for node in ${control[@]}; do 
    cp $authdir/$node.pem $dir/roles/install-control-certs/files
    cp $authdir/$node-key.pem $dir/roles/install-control-certs/files
    cp $authdir/$node.kubeconfig $dir/roles/install-control-certs/files
done

for cert in ${clientcerts[@]}; do
    cp $authdir/$cert $dir/roles/install-client-certs/files
done