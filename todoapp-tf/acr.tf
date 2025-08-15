##############################
# Container Registry (ACR)   #
##############################
resource "azurerm_container_registry" "acr" {
  name                = "todoappacr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false

  depends_on = [azurerm_resource_group.rg]
}

resource "random_string" "suffix" {
  length  = 3
  upper   = false
  special = false
}