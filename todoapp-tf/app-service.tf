# -------------------------------
# App Service Plan (B1 tier to avoid quota issues)
# -------------------------------
resource "azurerm_service_plan" "asp" {
  name                = "todoapp-asp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1" # Changed from S1 to B1 to avoid quota errors
}


# -------------------------------
# Web App for Container
# -------------------------------
resource "azurerm_linux_web_app" "webapp" {
  name                = "todoapp-webapp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      docker_image_name   = "todoapp:latest"
      docker_registry_url = azurerm_container_registry.acr.login_server
    }
  }

  tags = {
    environment = "production"
    app         = "todoapp-demo"
  }
}

# -------------------------------
# Grant Web App access to pull from ACR
# -------------------------------
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_linux_web_app.webapp.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

