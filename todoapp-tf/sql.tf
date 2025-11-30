resource "azurerm_mssql_server" "sqlserver" {
  name                         = "todo-sql-server-007"
  resource_group_name = azurerm_resource_group.rg.name
 location            = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = "abcd1234"
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
