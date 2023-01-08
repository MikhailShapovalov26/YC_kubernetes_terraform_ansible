output "network_id" {
  value = yandex_vpc_network.network.id
}

# output "subnet_ids" {
#   value = {
#     for k, v in yandex_vpc_subnet.subnet : k => v.id
#   }
# }
output "subnet_id" {
  value = values(yandex_vpc_subnet.subnet)[*].id
}
output "subnet_zone" {
  value = values(yandex_vpc_subnet.subnet)[*].zone
}