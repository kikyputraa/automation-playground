# Main VM Setup

This is the control machine where Terraform and Ansible are run from.

---

## 1. Install Terraform

```sh
sudo apt update && sudo apt install -y gnupg software-properties-common curl

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install -y terraform
```

---

## 2. Install Ansible

```sh
sudo apt update && sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
```

Verify both are installed:

```sh
terraform -version
ansible --version
```

---

## 3. Configure SSH Access

### Generate SSH Key

```sh
sudo apt install -y openssh-server
ssh-keygen -t rsa -b 4096
```

View the public key:

```sh
cat ~/.ssh/id_rsa.pub
```

### Open Firewall

```sh
sudo ufw allow 22/tcp
sudo ufw reload
```

### Copy Key to Template VM

```sh
ssh-copy-id <user>@<template-vm-ip>
```

Or manually on the template VM:

```sh
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "<your-public-key>" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### Enable Root Login on Template VM

```sh
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh
```

### Test Connection

```sh
ssh <user>@<template-vm-ip>
```

If it logs in without a password prompt, the setup is correct.
