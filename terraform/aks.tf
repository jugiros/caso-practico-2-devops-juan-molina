resource "azurerm_kubernetes_cluster" "cp2" {
  name                = "aks-casopractico2"
  location            = azurerm_resource_group.cp2.location
  resource_group_name = azurerm_resource_group.cp2.name
  dns_prefix          = "cp2aks${random_string.suffix.result}"

  default_node_pool {
    name       = "system"
    node_count = 1
    vm_size    = var.aks_node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = azurerm_container_registry.cp2.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.cp2.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}
