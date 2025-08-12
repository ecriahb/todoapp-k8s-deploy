# -------------------------------
# Azure Container Registry
# -------------------------------
resource "azurerm_container_registry" "acr" {
  name                = "todoappdemoregistry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

# -------------------------------
# Allow Web App to pull from ACR
# -------------------------------
resource "azurerm_role_assignment" "webapp_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.webapp.identity[0].principal_id
}