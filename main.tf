# Reference to existing Resource Group
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Create Storage Account for Terraform State
resource "azurerm_storage_account" "tfstate" {
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.main.name
  location                = data.azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  
  tags = var.tags
}

# Create Storage Container for Terraform State
resource "azurerm_storage_container" "tfstate" {
  name                 = var.container_name
  storage_account_name = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# Create Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.main.name
  location           = data.azurerm_resource_group.main.location
  sku                = var.acr_sku
  admin_enabled      = var.acr_admin_enabled
  
  tags = var.tags
}

# Create AKS Cluster with ACR integration
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location           = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix         = var.dns_prefix
  
  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_size_gb = 30
    vnet_subnet_id  = null
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
  
  tags = var.tags
}

# Configure Kubernetes provider to use the created AKS cluster
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.main.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
}

# Output the kubeconfig
resource "local_file" "kubeconfig" {
  filename = "kubeconfig"
  content  = azurerm_kubernetes_cluster.main.kube_config_raw
  
  depends_on = [azurerm_kubernetes_cluster.main]
}
