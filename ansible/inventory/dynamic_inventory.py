#!/usr/bin/env python3
"""Dynamic inventory: builds the 'app' group from Terraform's own outputs.

Instead of hand-editing hosts.ini with an IP that changes every time the VM
is recreated, this asks Terraform what it actually deployed and builds the
inventory from that. Run it directly to see the JSON, or point Ansible at
it with -i:

    ansible-playbook -i inventory/dynamic_inventory.py site.yml

Needs a Terraform state to read, so ../terraform must already be applied.
"""
import json
import os
import subprocess
import sys

TERRAFORM_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "terraform")


def terraform_outputs():
    result = subprocess.run(
        ["terraform", "output", "-json"],
        cwd=TERRAFORM_DIR,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        sys.stderr.write(
            "dynamic_inventory: 'terraform output -json' failed, "
            "is the infrastructure applied yet?\n" + result.stderr
        )
        return {}
    return {name: value["value"] for name, value in json.loads(result.stdout).items()}


def build_inventory():
    # CI has no access to the local Terraform state, so the CD pipeline
    # exports these as repository variables instead. Prefer them, and
    # fall back to `terraform output` for local/manual runs.
    bastion_ip = os.environ.get("BASTION_IP")
    app_ip = os.environ.get("APP_PRIVATE_IP")
    admin_user = os.environ.get("ADMIN_USERNAME")

    if not bastion_ip or not app_ip:
        outputs = terraform_outputs()
        bastion_ip = bastion_ip or outputs.get("bastion_public_ip")
        app_ip = app_ip or outputs.get("app_private_ip")
        admin_user = admin_user or outputs.get("admin_username", "azureuser")

    if not bastion_ip or not app_ip:
        # No deployed infrastructure yet: an empty inventory, not an error,
        # so `ansible-inventory --list` still works before the first apply.
        return {"_meta": {"hostvars": {}}}

    admin_user = admin_user or "azureuser"
    hostname = "agrocompare-vm"
    ssh_key = os.environ.get("ANSIBLE_SSH_PRIVATE_KEY_FILE", "~/.ssh/alu-devops")
    proxy_command = (
        f'ssh -i {ssh_key} -o StrictHostKeyChecking=accept-new '
        f'-W %h:%p {admin_user}@{bastion_ip}'
    )

    return {
        "app": {"hosts": [hostname]},
        "_meta": {
            "hostvars": {
                hostname: {
                    "ansible_host": app_ip,
                    "ansible_user": admin_user,
                    "ansible_ssh_private_key_file": ssh_key,
                    "ansible_ssh_common_args": (
                        f'-o StrictHostKeyChecking=accept-new -o ProxyCommand="{proxy_command}"'
                    ),
                }
            }
        },
    }


if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "--list":
        print(json.dumps(build_inventory()))
    elif len(sys.argv) == 3 and sys.argv[1] == "--host":
        print(json.dumps({}))
    else:
        sys.stderr.write("usage: dynamic_inventory.py --list | --host <name>\n")
        sys.exit(1)
