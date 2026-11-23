# Ansible

This configures the Azure VM Terraform creates and deploys AgroCompare onto it.

It's split into four roles, run in this order:
- `docker` — installs Docker and the Compose plugin
- `deploy` — logs into the Azure Container Registry, renders the production Compose file, then pulls and starts the already-built, already-scanned images
- `firewall` — turns on UFW, blocks everything by default, opens only SSH and the app port
- `ssh_hardening` — turns off SSH password login and root login

## Before running it

You need:
- The infrastructure already created (`terraform apply` in `../terraform`) — the app VM has no public IP, it's reachable only through the bastion
- Ansible installed (`pip install ansible-core`)
- The required collections, from `requirements.yml`:

```bash
ansible-galaxy collection install -r requirements.yml
```

- SSH access to the bastion (the VM itself is only reached by jumping through it)
- `acr_login_server`, `acr_username`, `acr_password` and `image_tag` passed as extra vars (the CD pipeline does this for you; see `.github/workflows/cd.yml`)

## Setup

There are two ways to tell Ansible where the VM is:

**Static (`inventory/hosts.example.ini`)** — copy it to `inventory/hosts.ini` and fill in the bastion/VM IPs yourself:

```bash
cd ../terraform && terraform output bastion_public_ip && terraform output app_private_ip
```

The file already has the `ProxyCommand` set up so SSH jumps through the bastion to reach the private VM. Make sure the key matches whichever public key you gave Terraform.

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
ansible-playbook -i inventory/dynamic_inventory.py site.yml
# or, with the static file:
ansible-playbook -i inventory/hosts.ini site.yml
```

First run takes a few minutes. Running it again is fine — every task,
including the Compose deploy, only reports "changed" when something
actually changed (confirmed by running it twice back to back and comparing
the `changed` count in the play recap).

Confirm it worked (through the load balancer's public IP, not the private VM directly):

```bash
cd ../terraform && terraform output lb_public_ip
curl http://<lb-ip>:8080/
curl http://<lb-ip>:8080/api/health
```

Syntax check only, doesn't touch the server:

```bash
ansible-playbook -i inventory/dynamic_inventory.py site.yml --syntax-check
```

## If something breaks

Can't connect at all? Give the VM a minute after `terraform apply`, and check your IP is actually allowed in the bastion's NSG (`my_ip_cidr` in terraform.tfvars).

Permission denied on SSH? Wrong private key in the inventory file.

App not responding after a run? SSH in and run `docker compose -f /opt/agrocompare/docker-compose.yml logs`.
