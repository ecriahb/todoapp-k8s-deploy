# -------------------------------
# App Service Plan
# -------------------------------
resource "azurerm_service_plan" "asp" {
  name                = "todoapp-asp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1" # Change if you need more capacity
}

# -------------------------------
# Web App for Container (from ACR)
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
      docker_image_name   = "todoapp:latest" # Just image:tag here
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
    }
  }

  tags = {
    environment = "production"
    app         = "todoapp-demo"
  }
}
