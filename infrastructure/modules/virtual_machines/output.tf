output "vm-public-endpoint" {
  value = azurerm_public_ip.airline.ip_address
}