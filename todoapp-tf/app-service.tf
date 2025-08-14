# -------------------------------
# App Service Plan (B1 tier to avoid quota issues)
# -------------------------------
resource "azurerm_service_plan" "asp" {
  name                = "todoapp-asp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "Central US"
  os_type             = "Linux"
  sku_name            = "B1" # Lower tier to avoid quota issues
}

# -------------------------------
# Web App for Container
# -------------------------------
resource "azurerm_linux_web_app" "webapp" {
  name                = "todoapp-webapp-prod"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      docker_image_name   = "todoapp:latest"
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
    }

    # Optional: Always restart container if it fails
    always_on = true
  }

  # App settings for container startup & logging
  app_settings = {
    WEBSITES_PORT                      = "80"  # Change to match your app's port
    #WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    DOCKER_ENABLE_CI                    = "true"
    WEBSITES_CONTAINER_START_TIME_LIMIT = "600"  # Allow 5 minutes for container startup
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
