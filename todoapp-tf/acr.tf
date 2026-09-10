##############################
# Container Registry (ACR)   #
##############################
resource "azurerm_container_registry" "acr" {
  name                = "agenticdevopsacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  # The CI service principal cannot create Azure RBAC role assignments.
  # Enable the registry admin credential so the workflow can create an
  # imagePullSecret in AKS without requiring roleAssignments/write.
  admin_enabled       = true

  depends_on = [azurerm_resource_group.rg]
}
