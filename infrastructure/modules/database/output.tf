output "mysql-public-endpoint" {
  value = azurerm_mysql_server.airlinedemo_mysql.fqdn
}