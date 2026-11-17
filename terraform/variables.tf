# Owner: Jongkuch1 (Summative Part 1: network, bastion, private VM, load balancer)
variable "subscription_id" {
  description = "Azure subscription ID. Leave null to use the ARM_SUBSCRIPTION_ID environment variable."
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region to deploy into. Must be a region your subscription allows (see: az account list-locations -o table)."
  type        = string
}

variable "project_name" {
  description = "Short name used as a prefix for every resource."
  type        = string
  default     = "agrocompare"
}

variable "environment" {
  description = "Environment label (dev, test, prod). Used in resource names and tags."
  type        = string
  default     = "dev"
}

variable "vnet_address_space" {
  description = "Address space of the virtual network."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "public_subnet_prefix" {
  description = "Subnet for the bastion host (inside vnet_address_space)."
  type        = string
  default     = "10.20.1.0/24"
}

variable "private_subnet_prefix" {
  description = "Subnet for the app VM. It has no public IPs (inside vnet_address_space)."
  type        = string
  default     = "10.20.2.0/24"
}

variable "app_vm_size" {
  description = "Azure VM size of the app server."
  type        = string
  default     = "Standard_B2s"
}

variable "bastion_vm_size" {
  description = "Azure VM size of the bastion host (a small jump box is enough)."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Linux admin user created on both VMs (SSH key login only, no password)."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH PUBLIC key that will be allowed to log in to the VMs."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR form (for example 203.0.113.10/32). Only this address may reach SSH on the bastion."
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip_cidr, 0)) && var.my_ip_cidr != "0.0.0.0/0"
    error_message = "my_ip_cidr must be a valid CIDR such as 203.0.113.10/32, and must not be 0.0.0.0/0."
  }
}

variable "app_port" {
  description = "TCP port the web frontend listens on, on the app VM (docker-compose maps 8080 to nginx)."
  type        = number
  default     = 8080

  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535
    error_message = "app_port must be between 1 and 65535."
  }
}

variable "tags" {
  description = "Extra tags added to every resource."
  type        = map(string)
  default     = {}
}
