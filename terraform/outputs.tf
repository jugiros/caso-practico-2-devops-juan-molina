output "acr_login_server" {
  value = azurerm_container_registry.cp2.login_server
}

output "vm_public_ip" {
  value = azurerm_public_ip.cp2_vm.ip_address
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.cp2.name
}

output "resource_group_name" {
  value = azurerm_resource_group.cp2.name
}

resource "local_file" "ansible_vars" {
  filename = "${path.module}/../ansible/group_vars/all.yml"
  content  = <<-YAML
    acr_login_server: "${azurerm_container_registry.cp2.login_server}"
    acr_admin_username: "${azurerm_container_registry.cp2.admin_username}"
    acr_admin_password: "${azurerm_container_registry.cp2.admin_password}"
    vm_public_ip: "${azurerm_public_ip.cp2_vm.ip_address}"
    resource_group_name: "${azurerm_resource_group.cp2.name}"
    aks_name: "${azurerm_kubernetes_cluster.cp2.name}"
  YAML
}
