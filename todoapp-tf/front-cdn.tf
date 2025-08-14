# -------------------------------
# Locals for Front Door
# -------------------------------
locals {
  frontdoor_name       = "todoapp-fd"
  frontend_endpoint    = "todoapp-fd-ep"
  backend_pool_name    = "todoapp-appgw-backend"
  lb_settings_name     = "todoapp-lb-settings"
  health_probe_name    = "todoapp-health-probe"
  routing_rule_name    = "todoapp-route"
}

# -------------------------------
# Front Door Profile
# -------------------------------
resource "azurerm_frontdoor" "fd" {
  name                = local.frontdoor_name
  resource_group_name = azurerm_resource_group.rg.name

  frontend_endpoint {
    name      = local.frontend_endpoint
    host_name = azurerm_linux_web_app.webapp.default_site_hostname  # Front Door public hostname
    session_affinity_enabled = false
    session_affinity_ttl_seconds = 0
  }

  backend_pool {
    name = local.backend_pool_name

    backend {
      address     = azurerm_application_gateway.appgateway.frontend_ip_configuration[0].private_ip_address
      host_header = azurerm_application_gateway.appgateway.frontend_ip_configuration[0].private_ip_address
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 50
    }

    load_balancing_name = local.lb_settings_name
    health_probe_name   = local.health_probe_name
  }

  backend_pool_load_balancing {
    name                         = local.lb_settings_name
    additional_latency_milliseconds = 0
  }

  backend_pool_health_probe {
    name                = local.health_probe_name
    protocol            = "Http"
    path                = "/"
    interval_in_seconds = 30
    enabled             = true
  }

  routing_rule {
    name               = local.routing_rule_name
    accepted_protocols = ["Http"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [local.frontend_endpoint]

    forwarding_configuration {
      backend_pool_name   = local.backend_pool_name
      forwarding_protocol = "HttpOnly"
    }
  }

  depends_on = [
    azurerm_application_gateway.appgateway
  ]
}
