# Terraform: AgroCompare infrastructure on Azure

This folder creates the cloud infrastructure that AgroCompare runs on.
Terraform builds the empty server; the Ansible playbook in `../ansible/`
then installs Docker on it and deploys the app.

## What it creates

| Resource | Purpose |
|---|---|
| Resource group | One container for everything, so a single `destroy` removes it all |
| Virtual network + subnet | The private network the server lives in (`10.20.0.0/16`, `10.20.1.0/24`) |
| Network security group (NSG) | The firewall: SSH only from **your** IP, the web port open to the internet, everything else denied |
| Public IP (static) + network interface | Gives the VM an address you can reach |
| Linux VM (Ubuntu 22.04, `Standard_B2s`) | The compute instance. Password login is disabled; SSH key only |

Nothing secret is stored in the code. Region, your IP, the SSH key path and the
subscription ID are all variables.

## Files

| File | What it holds |
|---|---|
| `versions.tf` | Terraform and provider versions |
| `variables.tf` | Every input, with descriptions and validation |
| `main.tf` | The resources |
| `outputs.tf` | IP address, resource IDs, SSH command, app URL, Ansible inventory |
| `terraform.tfvars.example` | Template for your own `terraform.tfvars` (git-ignored) |

## Before you start

1. Install [Terraform](https://developer.hashicorp.com/terraform/install) 1.5 or newer and the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli).
2. Sign in and pick the subscription:
   ```bash
   az login
   export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
   ```
3. Make sure you have an SSH key pair (the **public** key is what Terraform uses):
   ```bash
   ls ~/.ssh/*.pub        # create one with: ssh-keygen -t ed25519
   ```

## How to initialise and apply

```bash
cd terraform

# 1. Create your own variables file and edit the three values inside it
cp terraform.tfvars.example terraform.tfvars
#    location            -> a region your subscription allows
#                           (az account list-locations -o table)
#    my_ip_cidr          -> your public IP + /32   (curl -s ifconfig.me)
#    ssh_public_key_path -> path to your .pub key

# 2. Download the provider
terraform init

# 3. Check the code and see what will be created (nothing is built yet)
terraform fmt -check
terraform validate
terraform plan

# 4. Build it (type "yes" when asked)
terraform apply

# 5. Read the results
terraform output
```

Expected result: `Plan: 8 to add` (resource group, virtual network, subnet, NSG,
NSG association, public IP, network interface, VM), then `Apply complete!`.

## Outputs

| Output | Meaning |
|---|---|
| `public_ip_address` | Address of the VM |
| `private_ip_address` | Address inside the subnet |
| `admin_username` | User to SSH in as |
| `ssh_command` | Ready-to-use SSH command |
| `app_url` | Where the frontend will answer once Ansible has deployed it |
| `resource_group_name`, `vnet_id`, `subnet_id`, `nsg_id`, `vm_id` | Resource IDs |
| `ansible_inventory` | Inventory text for the Ansible playbook |

Hand the server to Ansible:

```bash
terraform output -raw ansible_inventory > ../ansible/inventory/hosts.ini
```

## Giving a teammate SSH access

To let another teammate reach the VM (for the Ansible work, for example)
without changing your own `my_ip_cidr` or `ssh_public_key_path`, add their
IP and public key in your `terraform.tfvars`:

```hcl
team_ssh_cidrs                  = ["203.0.113.20/32"]
additional_ssh_public_key_paths = ["~/.ssh/teammate_id.pub"]
```

Each entry gets its own NSG rule and `admin_ssh_key` block, so access stays
visible per person and can be revoked individually later by removing their
entry and running `terraform apply` again. Then run:

```bash
terraform apply
terraform output public_ip_address
```

and send them the IP.

## Clean up (important: a running VM costs credit)

```bash
terraform destroy      # type "yes"
terraform state list   # should print nothing
```

## Troubleshooting

* **`RequestDisallowedByAzure` / region not allowed**: Azure for Students limits
  the regions. Pick another `location` from `az account list-locations -o table`.
* **`SkuNotAvailable` or quota error**: set a different `vm_size` in
  `terraform.tfvars`, for example `Standard_B1s` or `Standard_B2ms`.
* **`subscription ID could not be determined`**: run
  `export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)`.
* **`no such file or directory` for the SSH key**: fix `ssh_public_key_path`.
* **Locked out of SSH later**: your home IP changed. Update `my_ip_cidr` and run
  `terraform apply` again.

## State and safety notes

* State is stored locally in `terraform.tfstate` (git-ignored, it can hold
  sensitive values). Do not commit it.
* The SSH rule only allows `my_ip_cidr`, and the variable rejects `0.0.0.0/0`.
* Commit `.terraform.lock.hcl` after your first `terraform init`; it pins the
  provider version for everyone on the team.
