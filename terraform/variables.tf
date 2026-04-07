variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://192.168.1.6:8006/api2/json"
}

variable "pm_user" {
  description = "Proxmox user"
  type        = string
  default     = "root@pam"
}

variable "pm_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}

variable "pm_tls_insecure" {
  description = "Skip TLS verification"
  type        = bool
  default     = true
}

variable "target_node" {
  description = "Proxmox node name"
  type        = string
  default     = "server"
}

variable "vm_template" {
  description = "VM template name to clone from"
  type        = string
  default     = "template"
}

variable "vm_count" {
  description = "Number of VMs to provision"
  type        = number
  default     = 4
}

variable "vm_name_prefix" {
  description = "Prefix for VM names"
  type        = string
  default     = "devops-vm"
}

variable "vm_cores" {
  description = "Number of CPU cores per VM"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "RAM in MB per VM"
  type        = number
  default     = 2048
}

variable "vm_disk_size" {
  description = "Disk size per VM"
  type        = string
  default     = "25G"
}

variable "vm_storage" {
  description = "Proxmox storage pool"
  type        = string
  default     = "local-lvm"
}

variable "vm_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "ssh_public_key" {
  description = "SSH public key to inject into VMs"
  type        = string
}
