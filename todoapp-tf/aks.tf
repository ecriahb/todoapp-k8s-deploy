##############################
# AKS (in custom VNet)       #
##############################
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "agentic-devops-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "agentic-devops-aks"

  default_node_pool {
    name           = "systempool"
    node_count     = 2
    vm_size        = "Standard_D4as_v7"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  node_provisioning_profile {
    mode = "Manual"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"

    service_cidr   = "10.244.0.0/16"
    dns_service_ip = "10.244.0.10"
  }

  lifecycle {
    ignore_changes = [default_node_pool]
  }

  depends_on = [azurerm_subnet.aks_subnet]
}

# ACR authentication is handled by the deployment workflow because the
# CI service principal does not have Microsoft.Authorization/roleAssignments/write.
# This avoids a Terraform role-assignment failure for AcrPull.
