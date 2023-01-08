locals {
  type_vpcs = concat(var.type_vpcs, try(jsondecode(var.typevpcs_jsonencoded), []))
  typesets = { for vp in local.type_vpcs : (join(" ", compact(["${vp.name_subnet} ${vp.zone} ${one(vp.v4_cidr_blocks)}", try(vp.set_identifier, "")]))) => vp}
}

resource "yandex_vpc_network" "network" {
  name = var.name_network
}
resource "yandex_vpc_subnet" "subnet" {
  for_each       =  { for k, v in local.typesets : k => v }
  name           = each.value.name_subnet
  network_id     = yandex_vpc_network.network.id
  zone           = each.value.zone
  v4_cidr_blocks = each.value.v4_cidr_blocks
}
