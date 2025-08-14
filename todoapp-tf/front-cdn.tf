# -------------------------------
# Locals for Front Door
# -------------------------------
locals {
  fd_profile_name           = "todoapp-fd-profile"
  fd_endpoint_name          = "todoapp-fd-endpoint"
  fd_origin_group_webapp    = "todoapp-fd-og-webapp"
  fd_origin_group_appgw     = "todoapp-fd-og-appgw"
  fd_origin_webapp          = "todoapp-fd-origin-webapp"
  fd_origin_appgw           = "todoapp-fd-origin-appgw"
  fd_route_name             = "todoapp-fd-route"
}

# -------------------------------
# Front Door Profile
# -------------------------------
resource "azurerm_cdn_frontdoor_profile" "fd_profile" {
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
# Origin Groups
# -------------------------------
# Web App Origin Group
resource "azurerm_cdn_frontdoor_origin_group" "fd_origin_group_webapp" {
  name                     = local.fd_origin_group_webapp
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

# App Gateway Origin Group
resource "azurerm_cdn_frontdoor_origin_group" "fd_origin_group_appgw" {
  name                     = local.fd_origin_group_appgw
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id
  session_affinity_enabled = false

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = "/"
    request_type        = "HEAD"
    protocol            = "Http"
    interval_in_seconds = 30
  }
}

# -------------------------------
# Origins
# -------------------------------
# Web App Origin
resource "azurerm_cdn_frontdoor_origin" "fd_origin_webapp" {
  name                          = local.fd_origin_webapp
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd_origin_group_webapp.id

  host_name          = azurerm_linux_web_app.webapp.default_site_hostname
  http_port          = 80
  https_port         = 443
  origin_host_header = azurerm_linux_web_app.webapp.default_site_hostname
  certificate_name_check_enabled = false
}

# App Gateway Origin (internal)
resource "azurerm_cdn_frontdoor_origin" "fd_origin_appgw" {
  name                          = local.fd_origin_appgw
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd_origin_group_appgw.id

  host_name          = azurerm_application_gateway.appgateway.frontend_ip_configuration[0].private_ip_address
  http_port          = 80
  https_port         = 443
  origin_host_header = azurerm_application_gateway.appgateway.frontend_ip_configuration[0].private_ip_address
  certificate_name_check_enabled = false

  depends_on = [
    azurerm_application_gateway.appgateway
  ]
}

# -------------------------------
# Routing Rule
# -------------------------------
resource "azurerm_cdn_frontdoor_route" "fd_route" {
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
