# DevOps Automation Project

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/ansible-%231A1918.svg?style=for-the-badge&logo=ansible&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Nginx](https://img.shields.io/badge/nginx-%23009639.svg?style=for-the-badge&logo=nginx&logoColor=white)
![WordPress](https://img.shields.io/badge/WordPress-%2321759B.svg?style=for-the-badge&logo=WordPress&logoColor=white)
![Nextcloud](https://img.shields.io/badge/Nextcloud-%230082C9.svg?style=for-the-badge&logo=Nextcloud&logoColor=white)
![Owncloud](https://img.shields.io/badge/ownCloud-%231D2D44.svg?style=for-the-badge&logo=ownCloud&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white)

Infrastructure automation project using **Terraform** for VM provisioning and **Ansible** for service deployment. Runs on-premises with **Proxmox**.

---

## Project Structure

```
terraform/                        → VM provisioning on Proxmox
playbook/
  systemd/                        → Deploy services as systemd units
    cloud/                        → Nextcloud, OwnCloud
    docker/                       → Docker + Nginx, Docker + Kubernetes
    monitor/                      → Prometheus + Grafana
    wordpress/                    → WordPress
  dockerize/                      → Deploy services as Docker containers
    install_docker.yml            → Install Docker (run this first)
    monitoring_stack.yml          → Prometheus + Grafana (single stack)
    prometheus.yml
    grafana.yml
    wordpress.yml
    nextcloud.yml
    owncloud.yml
    nginx.yml
```

---

## Prerequisites

- [Terraform](https://www.terraform.io/downloads)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- SSH key configured for VM access
- Proxmox server with a prepared VM template

> See [VM Utama.md](VM%20Utama.md) and [VM Template.md](VM%20Template.md) for setup guides.

---

## Quick Start

### 1. Provision VMs with Terraform

Edit `terraform/main.tf` to match your Proxmox environment, then:

```sh
cd terraform
terraform init
terraform apply
```

### 2. Deploy a Service

**Option A — systemd** (installs directly on the OS):
```sh
ansible-playbook playbook/systemd/wordpress/wordpress.yml
```

**Option B — Docker** (runs as containers):
```sh
# Install Docker first (one-time per VM)
ansible-playbook playbook/dockerize/install_docker.yml

# Deploy the service
ansible-playbook playbook/dockerize/wordpress.yml
```

### Available Services

| Service | systemd | Docker |
|---|---|---|
| WordPress | `systemd/wordpress/wordpress.yml` | `dockerize/wordpress.yml` |
| Nextcloud | `systemd/cloud/nextcloud.yml` | `dockerize/nextcloud.yml` |
| OwnCloud | `systemd/cloud/owncloud.yml` | `dockerize/owncloud.yml` |
| Prometheus + Grafana | `systemd/monitor/monitor.yml` | `dockerize/monitoring_stack.yml` |
| Prometheus only | — | `dockerize/prometheus.yml` |
| Grafana only | — | `dockerize/grafana.yml` |
| Nginx | `systemd/docker/dockeronly.yml` | `dockerize/nginx.yml` |
| Kubernetes | `systemd/docker/docking_kubernets.yml` | — |

---

## Tools

| Tool | Purpose |
|---|---|
| Terraform | VM provisioning on Proxmox |
| Ansible | Service configuration and deployment |
| Prometheus | Metrics collection and monitoring |
| Grafana | Metrics visualization |
| Docker | Container runtime |
| Kubernetes | Container orchestration |
