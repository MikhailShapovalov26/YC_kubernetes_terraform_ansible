output "ip_adress" {
  value = yandex_kubernetes_node_group.node_group.instance_template[0].network_interface[0].subnet_ids
}
output "ip_adress_node" {
  value = yandex_kubernetes_node_group.node_group.instance_template[0].network_interface[0].subnet_ids
}
output "my_node_group" {
  value = yandex_kubernetes_node_group.node_group.*
}