output "external_ip" {
    value = values(yandex_alb_load_balancer.balancer)[0].listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}