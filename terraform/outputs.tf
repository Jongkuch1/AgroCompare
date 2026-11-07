output "resource_group_name" {
  description = "Name of the resource group holding everything (delete it to remove all resources)."
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.main.id
}

output "subnet_id" {
  description = "Resource ID of the subnet."
  value       = azurerm_subnet.app.id
}

output "nsg_id" {
  description = "Resource ID of the network security group."
  value       = azurerm_network_security_group.app.id
}

output "vm_id" {
  description = "Resource ID of the virtual machine."
  value       = azurerm_linux_virtual_machine.app.id
}

output "public_ip_address" {
  description = "Public IP address of the VM."
  value       = azurerm_public_ip.vm.ip_address
}

output "private_ip_address" {
  description = "Private IP address of the VM inside the subnet."
  value       = azurerm_network_interface.vm.private_ip_address
}

output "admin_username" {
  description = "Linux user to SSH in as."
  value       = var.admin_username
}

output "ssh_command" {
  description = "Command to log in to the VM (adjust the key path if yours is different)."
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.vm.ip_address}"
}

output "app_url" {
  description = "Where the web frontend will answer after the Ansible playbook has deployed it."
  value       = "http://${azurerm_public_ip.vm.ip_address}:${var.app_port}"
}

output "ansible_inventory" {
  description = "Ready-made Ansible inventory for this VM. Save it with: terraform output -raw ansible_inventory > ../ansible/inventory/hosts.ini"
  value       = "[app]\n${var.project_name}-vm ansible_host=${azurerm_public_ip.vm.ip_address} ansible_user=${var.admin_username}\n"
}
