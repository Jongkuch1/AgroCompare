#!/usr/bin/env python3
"""Dynamic inventory: builds the 'app' group from Terraform's own outputs.

Instead of hand-editing hosts.ini with an IP that changes every time the VM
is recreated, this asks Terraform what it actually deployed and builds the
inventory from that. Run it directly to see the JSON, or point Ansible at
it with -i:

    ansible-playbook -i inventory/dynamic_inventory.py playbook.yml

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
    outputs = terraform_outputs()
    host_ip = outputs.get("public_ip_address")
    if not host_ip:
        # No deployed infrastructure yet: an empty inventory, not an error,
        # so `ansible-inventory --list` still works before the first apply.
        return {"_meta": {"hostvars": {}}}

    admin_user = outputs.get("admin_username", "azureuser")
    hostname = "agrocompare-vm"
    ssh_key = os.environ.get("ANSIBLE_SSH_PRIVATE_KEY_FILE", "~/.ssh/alu-devops")

    return {
        "app": {"hosts": [hostname]},
        "_meta": {
            "hostvars": {
                hostname: {
                    "ansible_host": host_ip,
                    "ansible_user": admin_user,
                    "ansible_ssh_private_key_file": ssh_key,
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
