#!/usr/bin/env bash

control=(control{0,1,2})
workers=(worker{0,1,2})
vmnames=( "${control[@]}" "${workers[@]}" )

cafile=ca.pem
commoncerts=($cafile)
workercerts=(kube-proxy.kubeconfig)
controlcerts=(ca-key.pem 
kubernetes-key.pem kubernetes.pem 
service-account-key.pem service-account.pem 
admin.kubeconfig kube-controller-manager.kubeconfig
kube-scheduler.kubeconfig encryption-config.yaml
kube-proxy.kubeconfig)
clientcerts=(admin.pem admin-key.pem)