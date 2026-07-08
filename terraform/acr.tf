resource "azurerm_container_registry" "cp2" {
  name                = "${var.registry_name}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.cp2.name
  location            = azurerm_resource_group.cp2.location
  sku                 = var.registry_sku
  admin_enabled       = true
}
