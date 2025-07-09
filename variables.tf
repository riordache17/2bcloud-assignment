# Azure Subscription Variables
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "b99c0710-ded3-407b-b632-9fb5dd7edd13"
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  default     = "bd4f0481-b137-40f1-9e64-20cfd55fbf49"
}

# Azure Provider Variables
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "Robert-Lordache-Candidate"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "West Europe"  # Using West Europe as default, change if needed
}

# AKS Cluster Variables
variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "rbt-aks-cluster"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "rbt-aks"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "Size of the VMs in the node pool"
  type        = string
  default     = "Standard_DS2_v2"
}

# Storage Account for Terraform State
variable "storage_account_name" {
  description = "Name of the storage account for Terraform state"
  type        = string
  default     = "stgrbttfstate"
}

variable "container_name" {
  description = "Name of the container in the storage account for Terraform state"
  type        = string
  default     = "tfstate"
}

# ACR Variables
variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "rbtacr"
}

variable "acr_sku" {
  description = "The SKU name of the container registry"
  type        = string
  default     = "Basic"
}

variable "acr_admin_enabled" {
  description = "Specifies whether admin is enabled for the container registry"
  type        = bool
  default     = true
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Dev"
    Project     = "2bcloud-assignment"
    ManagedBy   = "Terraform"
  }
}
