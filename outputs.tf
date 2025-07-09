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

output "kube_config" {
  description = "The Kubernetes configuration to connect to the cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "host" {
  description = "The Kubernetes cluster server host"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.host
  sensitive   = true
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

# Output the kubeconfig filename for convenience
output "kubeconfig_filename" {
  value       = local_file.kubeconfig.filename
  description = "The filename of the generated kubeconfig file"
}

output "how_to__use_kubectl" {
  description = "Instructions for using kubectl with the new cluster"
  value       = <<EOT

  To use kubectl with the new cluster, run:
  
  1. Set the KUBECONFIG environment variable:
     export KUBECONFIG=${local_file.kubeconfig.filename}
  
  2. Verify cluster connection:
     kubectl get nodes
  
  Or use the kubeconfig file directly:
  kubectl --kubeconfig=${local_file.kubeconfig.filename} get nodes
  EOT
}
