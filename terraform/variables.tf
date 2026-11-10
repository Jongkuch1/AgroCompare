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

variable "subnet_prefix" {
  description = "Address prefix of the subnet the VM lives in (must sit inside vnet_address_space)."
  type        = string
  default     = "10.20.1.0/24"
}

variable "vm_size" {
  description = "Azure VM size. Standard_B2s is enough to run the two containers."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Linux admin user created on the VM (SSH key login only, no password)."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH PUBLIC key that will be allowed to log in to the VM."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR form (for example 203.0.113.10/32). Only this address may reach SSH."
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip_cidr, 0)) && var.my_ip_cidr != "0.0.0.0/0"
    error_message = "my_ip_cidr must be a valid CIDR such as 203.0.113.10/32, and must not be 0.0.0.0/0."
  }
}

variable "team_ssh_cidrs" {
  description = "Additional teammate public IPs (CIDR form), beyond my_ip_cidr, allowed to SSH in."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for c in var.team_ssh_cidrs : can(cidrhost(c, 0)) && c != "0.0.0.0/0"])
    error_message = "Each entry in team_ssh_cidrs must be a valid CIDR such as 203.0.113.10/32, and must not be 0.0.0.0/0."
  }
}

variable "additional_ssh_public_key_paths" {
  description = "Paths to additional teammates' SSH PUBLIC keys allowed to log in to the VM, beyond ssh_public_key_path."
  type        = list(string)
  default     = []
}

variable "app_port" {
  description = "Public TCP port of the web frontend (docker-compose maps it to 8080)."
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
