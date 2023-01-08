locals {
  type_instances = concat(var.type_instances, try(jsondecode(var.typeinstance_jsonencoded), []))
  typesets = { for rs in local.type_instances : (join(" ", compact(["${rs.image_id} ${rs.zone}  ${rs.name} ${rs.cores} ${rs.memory} ${rs.size} ${rs.nat} ${rs.user}", try(rs.set_identifier, "")]))) => rs }
  inst = null
}
resource "yandex_compute_instance" "instance" {
  for_each = { for k, v in local.typesets : k => v }
  name = each.value.name
  zone = each.value.zone

  resources {
    cores  = each.value.cores
    memory = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id = each.value.image_id
      size = each.value.size
    }
  }
  network_interface {
    subnet_id = "${var.subnet_id}"
    nat       =  each.value.nat
  }

  metadata = {
    user-data = (
      file("./data/user-data/${each.value.user}")
    )
  }
}