# output "instance_id" {
#   value = yandex_compute_instance.instance[*].id
# }

output "internal_ip_address" {
  value = values(yandex_compute_instance.instance)[*].network_interface.0.ip_address
}

output "external_ip_address" {
  value = values(yandex_compute_instance.instance)[*].network_interface.0.nat_ip_address
}