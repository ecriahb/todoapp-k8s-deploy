# -------------------------------
# Resource Group
# -------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "todoapp-demo-rg"
  location = "East US"
}
