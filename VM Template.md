# VM Template Setup (Proxmox)

Create a base VM on Proxmox, configure it, then convert it to a template. Every VM provisioned by Terraform will be cloned from this template.

---

## 1. Install Required Packages

```sh
sudo apt update && sudo apt install -y \
  qemu-guest-agent \
  openssh-server \
  python3 \
  python3-pip \
  python3-apt \
  sudo \
  curl \
  software-properties-common

sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
ansible --version
```

---

## 2. Install Node Exporter

Node Exporter is baked into the template so every cloned VM is monitored automatically.

```sh
# Download
wget https://github.com/prometheus/node_exporter/releases/download/v1.9.0/node_exporter-1.9.0.linux-amd64.tar.gz \
  -O /tmp/node_exporter.tar.gz

# Extract and move
tar -xzf /tmp/node_exporter.tar.gz -C /tmp/
sudo mv /tmp/node_exporter-* /opt/node_exporter

# Create dedicated user
sudo useradd -rs /bin/false node_exporter
sudo chown -R node_exporter:node_exporter /opt/node_exporter

# Create systemd service
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/opt/node_exporter/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter
systemctl status node_exporter
```

---

## 3. Configure SSH

```sh
# Enable root login for Ansible access
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# Add main VM's public key
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "<main-vm-public-key>" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Test from the main VM:

```sh
ssh <user>@<template-vm-ip>
```

---

## 4. Convert to Proxmox Template

```sh
# Shut down the VM
qm shutdown <VM_ID>

# Convert to template
qm template <VM_ID>
```

The template is now ready. Terraform will clone it when provisioning new VMs.
