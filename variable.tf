variable "location" {
  type        = string
  description = "Azure Region for resource deployment"
  default     = "Central US"
}

variable "resource_group_name" {
  type        = string
  description = "Base Resource Group name"
  default     = "terraform-aks"
}

variable "environment" {
  type        = string  
  description = "Deployment environment"  
  default     = "dev"
}

variable "ssh_public_key" {
  description = "SSH Public Key for Linux nodes"  
  default     = "~/.ssh/aks-prod-sshkeys-terraform/aksprodsshkey.pub"
}

variable "windows_admin_username" {
  type        = string
  description = "Windows admin username"  
  default     = "azureuser"
}

variable "windows_admin_password" {
  type        = string
  description = "Windows admin password (recommend Key Vault in production)"  
  default     = "P@ssw0rd1234"
}

