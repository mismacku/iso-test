packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.1.0"
    }
  }
}

variable "accelerator" {
  type    = string
  default = "kvm"
}

variable "cpus" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 1024
}

variable "ssh_username" {
  type    = string
  default = "cirros"
}

variable "ssh_password" {
  type    = string
  default = "cubswin:)"
}

source "qemu" "cirros" {
  disk_image = true
  iso_url    = "https://download.cirros-cloud.net/0.6.2/cirros-0.6.2-x86_64-disk.img"
  iso_checksum = "none"

  output_directory = "output/cirros-kvm-test"
  format           = "qcow2"

  accelerator = var.accelerator
  cpu_model   = var.accelerator == "kvm" ? "host" : "qemu64"
  headless    = true

  communicator     = "ssh"
  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_timeout      = "5m"
  ssh_pty          = true
  shutdown_command = "echo '${var.ssh_password}' | sudo -S poweroff"
  shutdown_timeout = "5m"

  qemuargs = [
    ["-m", "${var.memory}M"],
    ["-smp", "${var.cpus}"]
  ]
}

build {
  sources = ["source.qemu.cirros"]
}
