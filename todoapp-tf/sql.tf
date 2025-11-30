resource "azurerm_mssql_server" "sqlserver" {
  name                         = "todo-sql-server-001"
  resource_group_name          = "todoapp-rg"
  location                     = "eastus2"  # Change from current restricted region
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = var.sql_admin_password
}


# --------------------------
# SQL Database (todo)
# --------------------------
resource "azurerm_mssql_database" "todo_db" {
  name                = "todo"
  server_id           = azurerm_mssql_server.sqlserver.id
  sku_name            = "S0"         # Basic/S0/S1 आदि चुन सकते हैं
  max_size_gb         = 5
}
