output "vm-public-endpoint" {
  value = azurerm_public_ip.public_ip.ip_address
}