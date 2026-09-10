# resource "azurerm_mssql_server" "sqlserver" {
#   name                         = "agentic-devops-sql"
#   resource_group_name          = azurerm_resource_group.rg.name
#   location                     = azurerm_resource_group.rg.location
#   version                      = "12.0"
#   administrator_login          = "sqladminuser"
#   administrator_login_password = "abcd@@@!!!1234"
# }

# --------------------------
# SQL Database
# --------------------------

# resource "azurerm_mssql_database" "todo_db" {
#   name        = "agentsql"
#   server_id   = azurerm_mssql_server.sqlserver.id
#   sku_name    = "S0"
#   max_size_gb = 5
# }
