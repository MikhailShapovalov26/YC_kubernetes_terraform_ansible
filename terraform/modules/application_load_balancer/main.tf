locals {
  type_balance = concat(var.type_balance, try(jsondecode(var.typebalance_jsonencoded), []))
  typesets = { for rs in local.type_balance : (join(" ", compact(["${rs.name} ${rs.zone} ${rs.subnet_id} ${rs.name_listen}", try(rs.set_identifier, "")]))) => rs }
  inst = null
}
resource "yandex_alb_http_router" "tf-router" {
  name      = "router"
}
resource "yandex_alb_load_balancer" "balancer" {
  for_each = { for k, v in local.typesets : k => v }
  name        = each.value.name
  network_id = var.network_id

  allocation_policy {
    location {
      zone_id   = each.value.zone
      subnet_id = each.value.subnet_id
    }
  }

  listener {
    name = each.value.name_listen
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80, 443 ]
    }    
    http {
      handler {
        http_router_id = yandex_alb_http_router.tf-router.id
      }
    }
  }
}