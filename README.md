# Automated Kubernetes The Harder Way

****This is currently a WIP****

This repository is my attempt at adapting the steps in the repository [Kubernetes The Harder Way](https://github.com/ghik/kubernetes-the-harder-way/tree/macos) for a vanilla Kubernetes cluster over proxmox. It makes extensive use of Terraform for VM creation and Ansible for configuring deployed nodes.

## Cluster topology

All configuration assumes cluster machines are running on Ubuntu Server.

This cluster runs by default on 3 worker nodes and 3 control nodes, each with 2 vCPUs and 2GB of RAM. 

Additionally, there's a gateway machine that holds the DNS/DHCP server for the network, load balancing nginx for kube control nodes, as well  and which will later on in this project bear the MetalLB for Ingress communication from Internet to the pods. 

This gateway machine also serves as a bastion for Ansible execution and is used as a control machine for the cluster with `kubectl`.

## Network topology

All nodes live in a VERY LARGE network, `10.16.0.0/16`. This is on my TODO list of things to fix as this is way too large for a hobby cluster.
Control nodes live on `10.16.1.0/24` whilst workers are on `10.16.2.0/24`.

The gateway machine has two VNICs, one on the local network, through Proxmox `vmbr0`, the other in the cluster with two assigned IPs : `10.16.0.1/16` and `10.16.254.254/16` for the VIP.

The Kubernetes API is exposed through a nginx loadbalancer living on the gateway machine. 

The gateway machine also acts as a router to outbound internet traffic for cluster nodes.

All control nodes have the gateway VIP IP on their loopback device, `10.16.254.254/32` with ARP announce disabled to prevent collision with the `gateway`.

Additionally for ease of use, hostfile entries are added to each machine. Check out the `install-dnsmasq` role for more info.

Services will live on `10.32.0.0/16`, and pods will live on `10.64.0.0/16`, which will be split two ways :

- Control nodes will be assigned subnets `10.64.0-127.0/24`
- Worker nodes will be assigned subnets `10.64.128-255.0/24`



