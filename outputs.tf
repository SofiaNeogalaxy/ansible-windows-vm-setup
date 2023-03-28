output "resource_group_name" {
  value = azurerm_resource_group.win_rg
}

output "win_username" {
  value = azurerm_windows_virtual_machine.win_vm.admin_username
}

output "public_ip_address" {
  value = azurerm_windows_virtual_machine.win_vm.public_ip_address
}

