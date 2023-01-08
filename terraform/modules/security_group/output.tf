output "security_group_name" {
  value = yandex_vpc_security_group.k8s-main-sg.id
}