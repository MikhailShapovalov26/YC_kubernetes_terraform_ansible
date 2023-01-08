resource "yandex_kubernetes_cluster" "zonal_cluster" {
  name        = "${var.name_cluster}"

  network_id = "${var.network_id}"

  master {
    version = "1.22"
    zonal {
      zone      = "${var.zone}"
      subnet_id = "${var.subnet_id}"
    }

    public_ip = true

    security_group_ids = ["${var.security_group_ids}"]

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        start_time = "15:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = "${var.service_account_id}"
  node_service_account_id = "${var.node_service_account_id}"
}