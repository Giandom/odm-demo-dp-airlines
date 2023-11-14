resource "azurerm_mysql_server" "airlinedemo_mysql" {
  name                = "airlinedemo"
  location            = var.region
  resource_group_name = var.resource_group_name

  administrator_login          = "mysqladmin"
  administrator_login_password = "@1rl1n3D3m0!"

  sku_name   = "B_Gen5_1"
  version    = "8.0"

  auto_grow_enabled                 = false
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_minimal_tls_version_enforced  = "TLSEnforcementDisabled"
  ssl_enforcement_enabled           = false
  tags = var.project_tags
}

resource "azurerm_mysql_database" "airlinedemo" {
  name                = "airlinedemo"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.airlinedemo_mysql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_firewall_rule" "airlinedemo" {
  name                = "public"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.airlinedemo_mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
