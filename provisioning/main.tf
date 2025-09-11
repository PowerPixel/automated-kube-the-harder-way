terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc01"
    }
  }
}

# PM API TOKEN : terraform-prov@pve!tofu : 3d076306-ea09-4008-8464-1e4cc427ee0c
# Voir : https://search.opentofu.org/provider/telmate/proxmox/latest/docs/guides/cloud_init

provider "proxmox" {
  pm_api_url      = "https://192.168.1.112:8006/api2/json"
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "gateway" {
  name = "gateway"
  desc = "Kubernetes - Gateway"

  ciuser = "ubuntu"
  cipassword = "ubuntu"

  target_node = var.control-proxmox-node

  # The template name to clone this vm from
  clone = var.control-template

  # Activate QEMU agent for this VM
  agent = 1

  os_type = "cloud-init"
  ci_wait = 60

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }
  memory = 2048

  bios = "ovmf"

  boot     = "c"
  bootdisk = "scsi0"
  scsihw   = "virtio-scsi-pci"

  serial {
    id   = 0
    type = "socket"
  }

  disks {
    scsi {
      scsi0 {
        disk {
          size    = "20G"
          storage = "local-lvm"
        }
      }
      scsi1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
    macaddr = "14:12:8b:03:2e:8f"
  }
  ipconfig0 = "ip=dhcp"

  network {
    id     = 1
    model  = "virtio"
    bridge = "vmbr1"
    macaddr = "52:52:52:00:00:00"
  }
  ipconfig1 = "ip=10.16.0.1/16"

  sshkeys = file("./pubkey")
}

resource "null_resource" "configure_gateway" {
  depends_on = [proxmox_vm_qemu.gateway]

  provisioner "local-exec" {
    command = "ansible-playbook -i ../configuring/inventory.py --user ubuntu --become --become-method=sudo ../configuring/gateway.yaml"
    
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "proxmox_vm_qemu" "control-plane" {
  depends_on = [ null_resource.configure_gateway ]
  count = 3
  name  = "control${count.index}"
  desc  = "Kubernetes - Control Plane ${count.index}"

  # Node name has to be the same name as within the cluster
  # this might not include the FQDN
  target_node = var.control-proxmox-node

  # The template name to clone this vm from
  clone = var.control-template

  # Activate QEMU agent for this VM
  agent = 1

  os_type = "cloud-init"
  ci_wait = 60

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }
  memory = 2048

  bios = "ovmf"

  boot     = "c"
  bootdisk = "scsi0"
  scsihw   = "virtio-scsi-pci"

  serial {
    id   = 0
    type = "socket"
  }

  disks {
    scsi {
      scsi0 {
        disk {
          size    = "20G"
          storage = "local-lvm"
        }
      }
      scsi1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr1"
    macaddr = "52:52:52:00:01:${format("%02x", count.index)}"
  }
  ipconfig0 = "ip=dhcp"

  sshkeys = file("./pubkey")
}

resource "proxmox_vm_qemu" "workers" {
  depends_on = [ null_resource.configure_gateway ]

  count = 3
  name  = "worker${count.index}"
  desc  = "Kubernetes - Worker ${count.index}"

  # Node name has to be the same name as within the cluster
  # this might not include the FQDN
  target_node = var.control-proxmox-node

  # The template name to clone this vm from
  clone = var.control-template

  # Activate QEMU agent for this VM
  agent = 1

  os_type = "cloud-init"
  ci_wait = 60

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }
  memory = 2048

  bios = "ovmf"

  boot     = "c"
  bootdisk = "scsi0"
  scsihw   = "virtio-scsi-pci"

  serial {
    id   = 0
    type = "socket"
  }

  disks {
    scsi {
      scsi0 {
        disk {
          size    = "20G"
          storage = "local-lvm"
        }
      }
      scsi1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr1"
    macaddr = "52:52:52:00:02:${format("%02x", count.index)}"
  }
  ipconfig0 = "ip=dhcp"

  sshkeys = file("./pubkey")
}

resource "null_resource" "configure_k8s" {
  depends_on = [proxmox_vm_qemu.workers, proxmox_vm_qemu.control-plane]

  provisioner "local-exec" {
    command = "ansible-playbook -i ../configuring/inventory.py --user ubuntu --become --become-method=sudo ../configuring/k8s-cluster.yaml"
    
    interpreter = ["/bin/bash", "-c"]
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ../configuring/inventory.py --user ubuntu --become --become-method=sudo ../configuring/client.yaml"
    
    interpreter = ["/bin/bash", "-c"]
  }
}