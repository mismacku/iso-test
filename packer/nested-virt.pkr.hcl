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

source "qemu" "cirros" {
  disk_image = true
  iso_url    = "https://download.cirros-cloud.net/0.6.2/cirros-0.6.2-x86_64-disk.img"
  iso_checksum = "none"

  output_directory = "output/cirros-kvm-test"
  format           = "qcow2"

  accelerator = var.accelerator
  cpu_model   = "host"
  headless    = true

  communicator    = "none"
  shutdown_timeout = "2m"

  qemuargs = [
    ["-m", "${var.memory}M"],
    ["-smp", "${var.cpus}"]
  ]
}

build {
  sources = ["source.qemu.cirros"]
}
