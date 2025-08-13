# -------------------------------
# AKS Cluster
# -------------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "todoapp-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "todoappdemoaks"

  default_node_pool {
    name       = "systempool"
    node_count = 1
    vm_size    = "Standard_D2ps_v6"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "production"
    app         = "todoapp-demo"
  }
}

# -------------------------------
# Allow AKS to pull from ACR
# -------------------------------

# resource "azurerm_role_assignment" "tf_user_access_admin" {
#   scope                = "/subscriptions/ec998bb0-bbb9-4c41-8983-b66714ad3652"
#   role_definition_name = "User Access Administrator"
#   principal_id         = "ac4c038c-dada-4147-85da-245a2fe418e8"
# }


resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}