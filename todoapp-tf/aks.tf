##############################
# AKS (in custom VNet)       #
##############################
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "todoapp-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "todoapp-aks"

  default_node_pool {
    name           = "systempool"
    node_count     = 1
    vm_size        = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"

    # Avoid conflicts with VNet subnets
    service_cidr      = "10.244.0.0/16"  # Must not overlap with any subnet
    dns_service_ip    = "10.244.0.10"
  }

  lifecycle {
    ignore_changes = [default_node_pool]
  }

  depends_on = [azurerm_subnet.aks_subnet]
}

# Allow AKS Kubelet to pull from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  depends_on = [
    azurerm_container_registry.acr,
    azurerm_kubernetes_cluster.aks
  ]
}
