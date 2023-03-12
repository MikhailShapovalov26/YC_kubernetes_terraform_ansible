locals {
  name_network = "network"
  vpcs = {
    "vpcs" = {
      type_vpcs = [
        { name_subnet = "subnet", zone = "ru-central1-a", v4_cidr_blocks = ["192.168.0.0/24"], },
      ]
    }
  }
  family         = "fd8autg36kchufhej85b"
  user_data_file = "demo-instance-user-data-0.yaml"
  zone_subnet    = element(compact(one(module.vpcs.*.vpcs.subnet_zone)), 0)
  instancies = {
    "instancies" = {
      type_instances = [
        { image_id = local.family, zone = local.zone_subnet, name = "name1", cores = "4", memory = "8", size = "30", nat = true, user = local.user_data_file, },
        # { image_id = local.family, zone = local.zone_subnet, name = "name2", cores = "4", memory = "4", size = "30",  nat = true, user = local.user_data_file, },
      ]
    }
  }
  # Foo       = element(compact(one(module.instancies[*].instancies.external_ip_address)), 0)
  Foo = element(one(module.yc_alb.*.targets.yandex_alb_load_balancer),0)
  # Foo_kuber = one(module.yc_alb.*.load_balance.external_ip)
  zones = {
    "msh762.ru" = {
      name   = "msh762-zone",
      public = true,
      records = [
        { name = "", type = "A", ttl = 30, records = [local.Foo, ] },
        { name = "*.infra", type = "A", ttl = 30, records = [local.Foo, ] },
        { name = "gitlab", type = "A", ttl = 30, records = [local.Foo, ] },
      ]
    }
  }
  member_ingress = ["alb.editor", "vpc.publicAdmin", "certificate-manager.certificates.downloader", "compute.viewer"]

  targets = {
    "targets" = {
      type_targets = [
        {subnet_id = element(compact(one(module.vpcs.*.vpcs.subnet_id)), 0), ip_address = "192.168.0.32",},
      ]
    }
  }
    load_balance = {
    "load_balance" = {
      type_balance = [
        { name = "balancekuber", zone = local.zone, subnet_id = element(compact(one(module.vpcs.*.vpcs.subnet_id)), 0), name_listen = "namelisten", },
      ]

    }
  }
}
