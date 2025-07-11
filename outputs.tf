# Resource Group
output "resource_group_name" {
  description = "The name of the resource group"
  value       = data.azurerm_resource_group.main.name
}

# AKS Cluster
output "cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "cluster_kubernetes_version" {
  description = "The Kubernetes version of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.kubernetes_version
}

# Storage Account
output "storage_account_name" {
  description = "The name of the storage account for Terraform state"
  value       = azurerm_storage_account.tfstate.name
}

output "storage_container_name" {
  description = "The name of the storage container for Terraform state"
  value       = azurerm_storage_container.tfstate.name
}

# Output ACR details
output "acr_name" {
  value       = azurerm_container_registry.acr.name
  description = "The name of the Azure Container Registry"
}

output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "The login server URL of the ACR"
}

output "how_to__push_to_acr" {
  value = <<EOT
  To push your Docker image to ACR:
  1. Log in to ACR:
     az acr login --name ${azurerm_container_registry.acr.name}
  
  2. Tag your image:
     docker tag 2bcloud-app ${azurerm_container_registry.acr.login_server}/2bcloud-app:latest
  
  3. Push the image:
     docker push ${azurerm_container_registry.acr.login_server}/2bcloud-app:latest
  EOT
  description = "Instructions for pushing Docker images to ACR"
}