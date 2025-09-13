#!/bin/bash

# This is the commands you need to run to get the template running on proxmox
# I initially wanted to write that part with Packer but thanks to the packer plugins developers not maintaining it
# I have to do it this way :) I am rewriting it to fit my use case though, check https://github.com/PowerPixel/packer-plugin-proxmox

UBUNTU_VERSION=ubuntu-24.04
IMG_FOLDER=/var/lib/vz/template/iso
VM_DISK_POOL=vm-storage
EFI_STORAGE_POOL=local-lvm

cd $IMG_FOLDER

apt update -y
apt install libguestfs-tools -y

virt-customize -a $UBUNTU_VERSION-server-cloudimg-amd64.img --run-command "apt-get update && apt-get upgrade -y && apt install arping traceroute -y && ufw disable"
virt-customize -a $UBUNTU_VERSION-server-cloudimg-amd64.img --install qemu-guest-agent

qm create 9000 --name "ubuntu-template" --memory 1024 --cores 2 --net0 virtio,bridge=vmbr1 --bios ovmf
qm set 9000 --efidisk0 $EFI_STORAGE_POOL:0


qm importdisk 9000 $UBUNTU_VERSION-server-cloudimg-amd64.img $VM_DISK_POOL --format qcow2
qm set 9000 --scsihw virtio-scsi-pci --scsi0 $VM_DISK_POOL:9000/vm-9000-disk-0.qcow2

qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --ide2 $VM_DISK_POOL:cloudinit
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent enabled=1

qm template 9000