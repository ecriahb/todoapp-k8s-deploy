# -------------------------------
# Locals for Front Door
# -------------------------------
locals {
  fd_profile_name      = "todoapp-fd-profile"
  fd_endpoint_name     = "todoapp-fd-endpoint"
  fd_origin_group_name = "todoapp-fd-origin-group"
  fd_origin_webapp     = "todoapp-webapp-origin"
  fd_route_name        = "todoapp-fd-route"
}

# -------------------------------
# Front Door Profile
# -------------------------------
resource "azurerm_cdn_frontdoor_profile" "fd_profile" {
depends_on = [azurerm_linux_web_app.webapp]
  name                = local.fd_profile_name
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard_AzureFrontDoor"
}

# -------------------------------
# Front Door Endpoint
# -------------------------------
resource "azurerm_cdn_frontdoor_endpoint" "fd_endpoint" {

  name                     = local.fd_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id
}

# -------------------------------
# Front Door Origin Group
# -------------------------------
resource "azurerm_cdn_frontdoor_origin_group" "fd_origin_group_webapp" {
  name                     = local.fd_origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id
  session_affinity_enabled = false

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = "/"
    request_type        = "HEAD"
    protocol            = "Https"
    interval_in_seconds = 30
  }
}

# -------------------------------
# Front Door Origin pointing to Web App
# -------------------------------
resource "azurerm_cdn_frontdoor_origin" "fd_origin_webapp" {
    depends_on = [azurerm_linux_web_app.webapp]
  name                          = local.fd_origin_webapp
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd_origin_group_webapp.id

  host_name                      = "${azurerm_linux_web_app.webapp.name}.azurewebsites.net"
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = "${azurerm_linux_web_app.webapp.name}.azurewebsites.net"
  certificate_name_check_enabled = false
  priority                       = 1
  weight                         = 100
}

# -------------------------------
# Front Door Route
# -------------------------------
resource "azurerm_cdn_frontdoor_route" "fd_route_webapp" {
    depends_on = [azurerm_linux_web_app.webapp]
  name                          = local.fd_route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fd_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd_origin_group_webapp.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fd_origin_webapp.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpOnly"
  link_to_default_domain = true
  https_redirect_enabled = false
}

# -------------------------------
# Dependencies
# -------------------------------
# Ensure Front Door is deployed after Web App

