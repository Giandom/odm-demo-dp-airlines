output "mysql-endpoint" {
  value = module.database.mysql-public-endpoint
}

output "vm-endpoint" {
  value = module.virtual_machines.vm-public-endpoint
}