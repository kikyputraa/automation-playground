output "vm_names" {
  description = "Names of provisioned VMs"
  value       = [for vm in proxmox_vm_qemu.vm : vm.name]
}

output "vm_ips" {
  description = "IP addresses of provisioned VMs"
  value       = [for vm in proxmox_vm_qemu.vm : vm.default_ipv4_address]
}
