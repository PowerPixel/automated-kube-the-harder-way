variable "worker-proxmox-node" {
  type    = string
  default = "proxmox"
}

variable "control-proxmox-node" {
  type    = string
  default = "proxmox"
}

variable "control-template" {
  type    = string
  default = "ubuntu-template"
}

variable "worker-template" {
  type    = string
  default = "ubuntu-template"
}