# # -------------------------------
# # Locals
# # -------------------------------
# locals {
#   cdn_profile_name       = "todoapp-cdn-profile"
#   cdn_endpoint_name      = "todoapp-cdn-endpoint"
#   cdn_origin_group_name  = "todoapp-cdn-origin-group"
#   cdn_origin_name        = "todoapp-webapp-origin"
#   cdn_route_name         = "todoapp-cdn-route"
# }

# # -------------------------------
# # CDN Front Door Profile
# # -------------------------------
# resource "azurerm_cdn_frontdoor_profile" "cdn_profile" {
#     depends_on = [
#   azurerm_linux_web_app.webapp
# ]
#   name                = local.cdn_profile_name
#   resource_group_name = azurerm_resource_group.rg.name
#   sku_name            = "Standard_AzureFrontDoor"
# }

# # -------------------------------
# # CDN Front Door Endpoint
# # -------------------------------
# resource "azurerm_cdn_frontdoor_endpoint" "cdn_endpoint" {
#     depends_on = [
#   azurerm_linux_web_app.webapp
# ]
#   name                     = local.cdn_endpoint_name
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.cdn_profile.id
# }

# # -------------------------------
# # CDN Origin Group
# # -------------------------------
# resource "azurerm_cdn_frontdoor_origin_group" "cdn_origin_group" {
#     depends_on = [
#   azurerm_linux_web_app.webapp
# ]
#   name                     = local.cdn_origin_group_name
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.cdn_profile.id
#   session_affinity_enabled = false

#   load_balancing {
#     sample_size                 = 4
#     successful_samples_required = 3
#   }

#   health_probe {
#     path                = "/"
#     request_type        = "HEAD"
#     protocol            = "Https"
#     interval_in_seconds = 30
#   }
# }

# # -------------------------------
# # CDN Origin (Web App)
# # -------------------------------
# resource "azurerm_cdn_frontdoor_origin" "cdn_origin" {
#     depends_on = [
#   azurerm_linux_web_app.webapp
# ]
#   name                          = local.cdn_origin_name
#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.cdn_origin_group.id

#   host_name          = azurerm_linux_web_app.webapp.default_hostname
#   origin_host_header = azurerm_linux_web_app.webapp.default_hostname
#   http_port          = 80
#   https_port         = 443
#   priority           = 1
#   weight             = 1000
#   certificate_name_check_enabled = false
# }

# # -------------------------------
# # CDN Route
# # -------------------------------
# resource "azurerm_cdn_frontdoor_route" "cdn_route" {
#     depends_on = [
#   azurerm_linux_web_app.webapp
# ]
#   name                          = local.cdn_route_name
#   cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.cdn_endpoint.id
#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.cdn_origin_group.id
#   cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.cdn_origin.id]

#   supported_protocols    = ["Http", "Https"]
#   patterns_to_match      = ["/*"]
#   forwarding_protocol    = "HttpOnly"
#   link_to_default_domain = true
#   https_redirect_enabled = false
# }

# # Ensure dependencies

