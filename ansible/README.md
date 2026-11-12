# Ansible

This configures the Azure VM Terraform creates and deploys AgroCompare onto it.

It's split into four roles, run in this order:
- `docker` — installs Docker and the Compose plugin
- `deploy` — clones this repo onto the server and runs `docker compose` to build/start the app
- `firewall` — turns on UFW, blocks everything by default, opens only SSH and the app port
- `ssh_hardening` — turns off SSH password login and root login

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

There are two ways to tell Ansible where the VM is:

**Static (`inventory/hosts.ini`)** — get the IP yourself and hardcode it:

```bash
cd ../terraform && terraform output public_ip_address
```

```ini
[app]
agrocompare-vm ansible_host=<ip here> ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/your_key
```

Make sure the key matches whichever public key you gave Terraform.

**Dynamic (`inventory/dynamic_inventory.py`)** — reads the IP straight out of
Terraform's state instead, so it's always right even after the VM gets
recreated. Needs `../terraform` to already be applied. Set
`ANSIBLE_SSH_PRIVATE_KEY_FILE` if your key isn't `~/.ssh/alu-devops`:

```bash
ANSIBLE_SSH_PRIVATE_KEY_FILE=~/.ssh/your_key ansible-inventory -i inventory/dynamic_inventory.py --list
```

## Run it

```bash
cd ansible
ansible-playbook -i inventory/dynamic_inventory.py playbook.yml
# or, with the static file:
ansible-playbook -i inventory/hosts.ini playbook.yml
```

First run takes a few minutes. Running it again is fine — every task,
including the Compose deploy, only reports "changed" when something
actually changed (confirmed by running it twice back to back and comparing
the `changed` count in the play recap).

Confirm it worked:

```bash
curl http://<ip>:8080/
curl http://<ip>:8080/api/health
```

Syntax check only, doesn't touch the server:

```bash
ansible-playbook -i inventory/dynamic_inventory.py playbook.yml --syntax-check
```

## If something breaks

Can't connect at all? Give the VM a minute after `terraform apply`, and check your IP is actually allowed in the NSG (`my_ip_cidr` / `team_ssh_cidrs` in terraform.tfvars).

Permission denied on SSH? Wrong private key in the inventory file.

App not responding after a run? SSH in and run `docker compose -f /opt/agrocompare/docker-compose.yml logs`.
