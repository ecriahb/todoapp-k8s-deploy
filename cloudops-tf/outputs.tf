output "sql_connection_string" {
  description = "ODBC connection string consumed by incident microservices"
  value       = "Driver={ODBC Driver 17 for SQL Server};Server=tcp:${azurerm_mssql_server.sqlserver.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.todo_db.name};Uid=sqladminuser;Pwd=${random_password.sql_admin.result};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
  sensitive   = true
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sqlserver.fully_qualified_domain_name
}

output "sql_database_name" {
  value = azurerm_mssql_database.todo_db.name
}
