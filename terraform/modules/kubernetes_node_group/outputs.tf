output "ip_adress" {
  value = yandex_kubernetes_node_group.node_group.instance_template[0].network_interface[0].subnet_ids
}