#!/usr/bin/env bash

set -xe

. "$(dirname $0)/auth-vars.sh"

vmid=1
for vmname in ${control[@]}; do 
cat <<EOF > "$vmname-csr.json"
{
  "CN": "system:node:$vmname",
  "key": {
    "algo": "rsa",
    "size": 4096
  },
  "names": [
    {
      "C": "FR",
      "L": "Lyon",
      "O": "Kubernetes",
      "OU": "kubenet",
      "ST": "Rhone"
    }
  ],
  "hosts": [
    "$vmname",
    "$vmname.kubenet",
    "10.0.1.${vmid}"
  ]
}
EOF
vmid=$(($vmid + 1))
done

vmid=1
for vmname in ${workers[@]}; do 
cat <<EOF > "$vmname-csr.json"
{
  "CN": "system:node:$vmname",
  "key": {
    "algo": "rsa",
    "size": 4096
  },
  "names": [
    {
      "C": "FR",
      "L": "Lyon",
      "O": "Kubernetes",
      "OU": "kubenet",
      "ST": "Rhone"
    }
  ],
  "hosts": [
    "$vmname",
    "$vmname.kubenet",
    "10.0.2.${vmid}"
  ]
}
EOF
vmid=$(($vmid + 1))
done