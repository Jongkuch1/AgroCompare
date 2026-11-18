# Owner: Jongkuch1 (Summative Part 1: network, bastion, private VM, load balancer)
output "resource_group_name" {
  description = "Name of the resource group holding everything (delete it to remove all resources)."
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.main.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host (the only SSH entry point)."
  value       = azurerm_public_ip.bastion.ip_address
}

output "bastion_nsg_name" {
  description = "Name of the bastion's firewall. The CD pipeline adds a temporary SSH rule to it."
  value       = azurerm_network_security_group.public.name
}

output "app_private_ip" {
  description = "Private IP of the app VM (reachable only through the bastion)."
  value       = azurerm_network_interface.app.private_ip_address
}

output "lb_public_ip" {
  description = "Public IP of the load balancer: where users reach the app."
  value       = azurerm_public_ip.lb.ip_address
}

output "app_url" {
  description = "Public URL of the app after the pipeline or Ansible has deployed it."
  value       = "http://${azurerm_public_ip.lb.ip_address}"
}

output "admin_username" {
  description = "Linux user to SSH in as."
  value       = var.admin_username
}

output "ssh_bastion" {
  description = "Log in to the bastion."
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.bastion.ip_address}"
}

output "ssh_app_via_bastion" {
  description = "Log in to the private app VM by jumping through the bastion."
  value       = "ssh -J ${var.admin_username}@${azurerm_public_ip.bastion.ip_address} ${var.admin_username}@${azurerm_network_interface.app.private_ip_address}"
}

output "ansible_env" {
  description = "Environment variables the Ansible inventory reads. Run: eval \"$(terraform output -raw ansible_env)\""
  value       = "export BASTION_IP=${azurerm_public_ip.bastion.ip_address} APP_PRIVATE_IP=${azurerm_network_interface.app.private_ip_address}"
}
