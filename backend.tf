terraform {
  backend "azurerm" {
    resource_group_name  = "Robert-Lordache-Candidate"
    storage_account_name = "stgrbttfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
