# DevOps Automation Project - Steering

## Overview
This project is an infrastructure automation setup using **Terraform** (VM provisioning on Proxmox) and **Ansible** (configuration management & service deployment). The target environment is an on-premises server running **Proxmox**.

## Project Structure
```
terraform/        → VM provisioning on Proxmox
playbook/
  cloud/          → Nextcloud & Owncloud
  docker/         → Docker & Kubernetes
  monitor/        → Prometheus & Grafana
  wordpress/      → WordPress
```

## Conventions & Rules

### Terraform
- Provider: `Telmate/proxmox` version `~> 2.9.14`
- Proxmox target node: `server`
- VM clone template: `template`
- VM naming format: `devops-vm-<index>`
- Default storage: `local-lvm`, disk size `25G`
- Always use variables for anything that may change (VM count, node name, etc.)
- Never hardcode credentials — use variables or environment variables

### Ansible Playbook
- All playbooks use `become: yes`
- Default target: `localhost` (executed from the main VM)
- Use `template` (Jinja2 `.j2`) for dynamic configuration files
- Use the `systemd` module to manage services instead of `service` where possible
- Playbook folder structure: `playbook/<category>/` with a `templates/` subfolder for `.j2` files

### Monitoring Stack
- Prometheus version: `v2.51.2`
- Node Exporter version: `v1.9.0`
- Prometheus port: `9090`, Grafana port: `3000`
- Dedicated users: `prometheus`, `node_exporter`, `grafana`
- Prometheus data directory: `/data`
- Install directories: `/opt/prometheus`, `/opt/node_exporter`

### VM Template (Proxmox)
- Base OS: Ubuntu/Debian
- Required packages in template: `qemu-guest-agent`, `openssh-server`, `python3`, `ansible`, `node_exporter`
- SSH must be configured with key-based auth (passwordless)
- `PermitRootLogin yes` set in template for Ansible access

## Language & Documentation
- Documentation in English
- Code comments in English
- `.md` files follow the same format as existing files

---

## How to Use This Project for Your Infrastructure

This project is designed to be reusable. Follow these phases to adapt it to your own environment.

### Phase 1 — Prepare the Main VM (One-Time Setup)

This is your control machine — where Terraform and Ansible run from.

1. Install Terraform and Ansible:
   ```sh
   sudo apt update && sudo apt install -y terraform ansible
   ```
2. Generate an SSH keypair:
   ```sh
   ssh-keygen -t rsa -b 4096
   ```
3. Open SSH port on firewall:
   ```sh
   sudo ufw allow 22/tcp && sudo ufw reload
   ```

### Phase 2 — Prepare the VM Template on Proxmox (One-Time Setup)

Create a base VM on Proxmox, then:

1. Install required packages: `qemu-guest-agent`, `openssh-server`, `python3`, `ansible`
2. Install Node Exporter (so every cloned VM is monitored from the start)
3. Add the main VM's public key to `~/.ssh/authorized_keys`
4. Set `PermitRootLogin yes` in `/etc/ssh/sshd_config`
5. Convert the VM to a Proxmox template:
   ```sh
   qm shutdown <VM_ID>
   qm template <VM_ID>
   ```

### Phase 3 — Adapt Terraform for Your Environment

Edit `terraform/main.tf` to match your Proxmox setup:

```hcl
provider "proxmox" {
  pm_api_url  = "https://<your-proxmox-ip>:8006/api2/json"
  pm_user     = "root@pam"
  pm_password = "<your-password>"   # better: use TF_VAR_ env variable
}

resource "proxmox_vm_qemu" "vm" {
  target_node = "<your-node-name>"  # change from "server"
  clone       = "<your-template-name>"  # change from "template"
}
```

Then provision your VMs:
```sh
terraform init
terraform apply
```

This will clone the template `n` times (default: 4 VMs) and output their IPs.

### Phase 4 — Deploy Services with Ansible

SSH into the target VM, then run the relevant playbook:

| Goal | Playbook |
|---|---|
| Monitoring (Prometheus + Grafana) | `ansible-playbook playbook/monitor/monitor.yml` |
| WordPress | `ansible-playbook playbook/wordpress/wordpress.yml` |
| Nextcloud | `ansible-playbook playbook/cloud/nextcloud.yml` |
| OwnCloud | `ansible-playbook playbook/cloud/owncloud.yml` |
| Docker + Nginx | `ansible-playbook playbook/docker/dockeronly.yml` |
| Docker + Kubernetes | `ansible-playbook playbook/docker/docking_kubernets.yml` |

Each playbook is self-contained — it installs dependencies, configures the service, sets up systemd, and opens the required firewall ports.

### Things to Change Before Production Use

- Move hardcoded passwords (MySQL, Proxmox) to Ansible Vault or Terraform `TF_VAR_` environment variables
- Update `pm_api_url`, `target_node`, and `clone` in `terraform/main.tf` to match your Proxmox setup
- Update `vm_count` variable if you need more or fewer VMs
- For Kubernetes, define a proper Ansible inventory with `master` and `workers` host groups — it's the only playbook that requires multiple hosts
- Adjust Prometheus scrape targets in `playbook/monitor/templates/prometheus.yml.j2` to include your VM IPs
