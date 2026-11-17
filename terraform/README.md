<!-- Owner: Jongkuch1 (Summative Part 1: network, bastion, private VM, load balancer) -->
# Terraform: AgroCompare on Azure

Builds the network, the bastion host, the private app VM and the load balancer.
`registry.tf` and `database.tf` (AgertuDA) add the container registry and the
managed database in the same folder.

## Files

| File | What it holds |
|---|---|
| `versions.tf` | Terraform and provider versions |
| `variables.tf` | All inputs (no secrets, no hardcoded region) |
| `main.tf` | Naming, tags and the resource group |
| `network.tf` | Virtual network, public and private subnets, firewalls (NSGs) |
| `bastion.tf` | Bastion host (public subnet, SSH from one IP) |
| `compute.tf` | App VM (private subnet, no public IP) |
| `loadbalancer.tf` | Public load balancer, health probe, web rule |
| `registry.tf`, `database.tf` | Container registry and PostgreSQL (AgertuDA) |
| `outputs.tf` | Addresses and ready-made SSH and Ansible commands |

## Use it

```bash
az login
cp terraform.tfvars.example terraform.tfvars   # fill in location, your IP (x.x.x.x/32), key path
terraform init
terraform validate
terraform plan
terraform apply
terraform output
```

Useful outputs: `app_url`, `bastion_public_ip`, `app_private_ip`, `ssh_app_via_bastion`.

## Costs and cleaning up

The bastion, app VM, load balancer, registry and database all use credits while they exist.

```bash
terraform destroy
```

## Troubleshooting

* **`RequestDisallowedByAzure` or "region not allowed"**: pick another `location` from `az account list-locations -o table`.
* **Database or VM size not available in the region**: change the region, or set `app_vm_size` / `db_sku_name`.
* **No SSH access after your IP changed**: update `my_ip_cidr` in `terraform.tfvars` and run `terraform apply`.
* **Never commit** `terraform.tfvars`, `*.tfstate` or any private key (they are git-ignored).
