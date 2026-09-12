# # -------------------------------
# # Locals for App Gateway
# # -------------------------------
# locals {
#   backend_address_pool_name      = "todoapp-beap"
#   frontend_port_name             = "todoapp-feport"
#   frontend_ip_configuration_name = "todoapp-feip"
#   http_setting_name              = "todoapp-be-htst"
#   http_listener_name             = "todoapp-httplstn"
#   request_routing_rule_name      = "todoapp-rqrt"
# }

# # Internal Application Gateway for AKS
# resource "azurerm_application_gateway" "appgateway" {
#   name                = "todoapp-appgw"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location

#   sku {
#     name     = "Standard_v2"
#     tier     = "Standard_v2"
#     capacity = 1
#   }

#   gateway_ip_configuration {
#     name      = "appgw-ip-config"
#     subnet_id = azurerm_subnet.appgw_subnet.id
#   }

#   frontend_port {
#     name = local.frontend_port_name
#     port = 80
#   }

#   # Private frontend only
#   frontend_ip_configuration {
#     name                          = local.frontend_ip_configuration_name
#     subnet_id                     = azurerm_subnet.appgw_subnet.id
#     private_ip_address_allocation = "Dynamic"
#   }

#   # Backend pool — internal AKS LB IP from your service
#   backend_address_pool {
#     name         = local.backend_address_pool_name
#     ip_addresses = [var.aks_internal_lb_ip]
#   }

#   backend_http_settings {
#     name                           = local.http_setting_name
#     cookie_based_affinity          = "Disabled"
#     port                           = 80
#     protocol                       = "Http"
#     request_timeout                = 30
#     pick_host_name_from_backend_address = false
#     probe_name                     = "aks-health-probe"
#   }

#   # Health probe for AKS service
#   probe {
#     name                = "aks-health-probe"
#     protocol            = "Http"
#     path                = "/"
#     interval            = 30
#     timeout             = 30
#     unhealthy_threshold = 3
#     pick_host_name_from_backend_http_settings = false
#     port                = 80
#   }

#   http_listener {
#     name                           = local.http_listener_name
#     frontend_ip_configuration_name = local.frontend_ip_configuration_name
#     frontend_port_name             = local.frontend_port_name
#     protocol                       = "Http"
#   }

#   request_routing_rule {
#     name                       = local.request_routing_rule_name
#     rule_type                  = "Basic"
#     http_listener_name         = local.http_listener_name
#     backend_address_pool_name  = local.backend_address_pool_name
#     backend_http_settings_name = local.http_setting_name
#     priority                   = 100
#   }

#   depends_on = [
#     azurerm_subnet.appgw_subnet,
#     azurerm_kubernetes_cluster.aks
#   ]

#   lifecycle {
#     ignore_changes = [
#       tags
#     ]
#   }
# }