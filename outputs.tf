output "resource_group_name" {
  value = azurerm_resource_group.zitrg.name
}

output "public_ip_address" {

  value = azurerm_windows_virtual_machine.zitwebserver.public_ip_address

}

