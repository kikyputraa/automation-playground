terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  pm_tls_insecure = var.pm_tls_insecure
}

resource "proxmox_vm_qemu" "vm" {
  count       = var.vm_count
  name        = "${var.vm_name_prefix}-${count.index + 1}"
  target_node = var.target_node
  clone       = var.vm_template

  cores   = var.vm_cores
  sockets = 1
  memory  = var.vm_memory

  disk {
    size    = var.vm_disk_size
    type    = "scsi"
    storage = var.vm_storage
  }

  network {
    model  = "virtio"
    bridge = var.vm_bridge
  }

  # Inject SSH public key via cloud-init
  sshkeys = var.ssh_public_key

  provisioner "local-exec" {
    command = "echo ${self.default_ipv4_address} >> ~/vm_ips.txt"
  }
}
