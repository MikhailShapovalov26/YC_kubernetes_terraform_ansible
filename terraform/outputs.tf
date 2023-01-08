output "networks" {
  value = module.vpcs.*
}
output "networks-1" {
  value = one(module.vpcs.*.vpcs.network_id)
}
output "subnet-1" {
  value = one(module.vpcs.*.vpcs.subnet_id)
}
output "test" {
  value = element(compact(one(module.vpcs.*.vpcs.subnet_id)), 0)
}
output "test2" {
  value = element(compact(one(module.vpcs.*.vpcs.subnet_zone)), 0)
}
output "instances" {
  value = one(module.instancies[*].instancies.external_ip_address)
}
output "security_group_name" {
  value = module.k8s_security_group.security_group_name
}

output "json_key" {
  value =  "${jsonencode({
    "id" = module.service_account.id,
    "service_account_id" = module.service_account.service_account_id_i,
    "created_at" = module.service_account.created_at,
    "key_algorithm" = module.service_account.key_algorithm,
    "public_key" = module.service_account.public_key,
    "private_key" = module.service_account.private_key

  })}"
  sensitive = true
  
}