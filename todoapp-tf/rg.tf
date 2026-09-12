# -------------------------------
# Resource Group
# -------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "agentic-devops-rg"
  location = "South India"
}
