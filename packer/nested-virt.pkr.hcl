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
  default = "gocubsgo"
}

variable "efi_firmware_code" {
  type    = string
  default = "/opt/homebrew/Cellar/qemu/10.2.0/share/qemu/edk2-aarch64-code.fd"
}

variable "efi_firmware_vars" {
  type    = string
  default = "builds/opensuse/leap-16/aarch64/efi/edk2-aarch64-vars.fd"
}

source "qemu" "cirros" {
  disk_image = true
  iso_url    = "https://download.cirros-cloud.net/0.6.2/cirros-0.6.2-aarch64-disk.img"
  iso_checksum = "none"

  output_directory = "output/cirros-kvm-test-aarch64"
  format           = "qcow2"

  qemu_binary = "qemu-system-aarch64"
  machine_type = "virt"
  disk_interface = "virtio-scsi"
  skip_compaction = true
  efi_firmware_code = var.efi_firmware_code
  efi_firmware_vars = var.efi_firmware_vars
  accelerator = var.accelerator
  cpu_model   = var.accelerator == "tcg" ? "max" : "host"
  headless    = true

  communicator     = "ssh"
  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_timeout      = "15m"
  ssh_pty          = true
  shutdown_command = "echo '${var.ssh_password}' | sudo -S poweroff"
  shutdown_timeout = "5m"

  qemuargs = [
    ["-m", "${var.memory}M"],
    ["-smp", "${var.cpus}"],
    ["-boot", "d"],
    ["-device", "virtio-gpu-pci"],
    ["-device", "usb-ehci"],
    ["-device", "usb-kbd"],
    ["-device", "usb-tablet"],
    ["-device", "virtio-scsi-pci,id=scsi0"],
    ["-device", "scsi-hd,bus=scsi0.0,drive=drive0"],
    ["-device", "virtio-net,netdev=user.0"]
  ]
}

build {
  sources = ["source.qemu.cirros"]
}
