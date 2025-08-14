##########################################
# App Service Plan & Web App (frontend)  #
##########################################
resource "azurerm_service_plan" "asp" {
  name                = "todoapp-asp"
  resource_group_name = azurerm_resource_group.rg.name
  location           = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "todoapp-webapp-prod"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = true
    application_stack {
      docker_image_name   = "todoapp:latest"
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
    }
  }

  app_settings = {
    WEBSITES_PORT                         = "80"
    DOCKER_ENABLE_CI                      = "true"
    WEBSITES_CONTAINER_START_TIME_LIMIT   = "600"
  }

  tags = {
    environment = "production"
    app         = "todoapp-demo"
  }

  depends_on = [
    azurerm_container_registry.acr,
    azurerm_service_plan.asp
  ]
}

# Allow Web App to pull from ACR
resource "azurerm_role_assignment" "webapp_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.webapp.identity[0].principal_id

  depends_on = [
    azurerm_container_registry.acr,
    azurerm_linux_web_app.webapp
  ]
}

# VNet Integration for Web App to reach private resources if needed
resource "azurerm_app_service_virtual_network_swift_connection" "webapp_vnet_integration" {
  app_service_id = azurerm_linux_web_app.webapp.id
  subnet_id      = azurerm_subnet.webapp_subnet.id

  depends_on = [
    azurerm_linux_web_app.webapp,
    azurerm_subnet.webapp_subnet
  ]
}
