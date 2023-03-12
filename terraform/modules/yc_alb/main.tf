locals {
    type_targets = concat(var.type_targets, try(jsondecode(var.typetarget_jsonencoded), []))
    typetarg = { for rs in local.type_targets : (join(" ", compact(["${rs.subnet_id} ${rs.ip_address}", try(rs.set_identifier, "")]))) => rs}
}
resource "yandex_alb_target_group" "target" {
  name = "target"
  for_each = { for k, v in local.typetarg : k => v }
  target {
    subnet_id = each.value.subnet_id
    ip_address = each.value.ip_address
  }
}
resource "yandex_alb_http_router" "tf-router" {
  name      = "router"
}

resource "yandex_alb_backend_group" "backend-group" {
  name      = "backend-group"
  http_backend {
    name = "http-backend"
    weight = 1
    port = 443
    target_group_ids = [ for k, v in yandex_alb_target_group.target: v.id ]
    # target_group_ids = ["${yandex_alb_target_group.target[0].id}"] 
    healthcheck {
      timeout = "1s"
      interval = "1s"
      http_healthcheck {
        path  = "/"
      }
    }
    http2 = "true"
  }
}
resource "yandex_alb_virtual_host" "virtual-host" {
  name      = "virtual-host"
  http_router_id = "${yandex_alb_http_router.tf-router.id}"
  route {
    name = "route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group.id
        timeout = "3s"
      }
    }
  }
}
resource "yandex_alb_load_balancer" "balancer" {
  for_each = { for k, v in local.typetarg : k => v }
  name        = "balancer"
  network_id = var.network_id

  allocation_policy {
    location {
      zone_id   = var.zone
      subnet_id = each.value.subnet_id
    }
  }

  listener {
    name = "list"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80, 443]
    }    
    http {
      handler {
        http_router_id = yandex_alb_http_router.tf-router.id
      }
    }
  }
}