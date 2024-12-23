terraform {
  backend "azurerm" {
    resource_group_name  = "cloud-shell-storage"
    storage_account_name = "mycloudshellstorag"
    container_name       = "terraform"
    key                  = "terraform.tfstate"

  }
}