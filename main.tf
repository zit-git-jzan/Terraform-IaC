resource "azurerm_resource_group" "zitrg" {
  name     = var.azure_rg_name
  location = var.azure_location

  tags = local.tags

}
