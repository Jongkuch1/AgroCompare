# Ansible

This configures the Azure VM Terraform creates and deploys AgroCompare onto it.

It does four things:
- Installs Docker and the Compose plugin
- Clones this repo onto the server and runs `docker compose` to build/start the app
- Turns on UFW, blocks everything by default, opens only SSH and 8080
- Turns off SSH password login and root login

## Before running it

You need:
- A VM already created (`terraform apply` in `../terraform`)
- Ansible installed (`pip install ansible-core`)
- Two extra collections:

```bash
ansible-galaxy collection install community.docker community.general
```

- SSH access to the VM

## Setup

Get the VM's IP:

```bash
cd ../terraform && terraform output public_ip_address
```

Put it in `inventory/hosts.ini`:

```ini
[app]
agrocompare-vm ansible_host=<ip here> ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/your_key
```

Make sure the key matches whichever public key you gave Terraform.

## Run it

```bash
cd ansible
ansible-playbook -i inventory/hosts.ini playbook.yml
```

First run takes a few minutes. Running it again is fine, it won't redo things that are already set up correctly (docker compose always reports "changed" since it rebuilds, everything else only changes the first time).

Confirm it worked:

```bash
curl http://<ip>:8080/
curl http://<ip>:8080/api/health
```

Syntax check only, doesn't touch the server:

```bash
ansible-playbook -i inventory/hosts.ini playbook.yml --syntax-check
```

## If something breaks

Can't connect at all? Give the VM a minute after `terraform apply`, and check your IP is actually allowed in the NSG (`my_ip_cidr` / `team_ssh_cidrs` in terraform.tfvars).

Permission denied on SSH? Wrong private key in the inventory file.

App not responding after a run? SSH in and run `docker compose -f /opt/agrocompare/docker-compose.yml logs`.
