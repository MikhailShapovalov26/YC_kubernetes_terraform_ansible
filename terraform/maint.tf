module "service_account" {
  source                       = "./modules/service_account"
  name_service_account_sa      = "kube-infra"
  name_service_account_ingress = "ingress-controller"
  member_ingress               = local.member_ingress
  folder_id                    = local.folder_id
}
module "vpcs" {
  source       = "./modules/vpcs"
  name_network = local.name_network
  for_each     = local.vpcs
  type_vpcs    = lookup(each.value, "type_vpcs")
}
module "yc_alb" {
  source = "./modules/yc_alb"
  for_each = local.targets
  type_targets = lookup(each.value, "type_targets")
  zone=local.zone
  network_id   = one(module.vpcs.*.vpcs.network_id)
  depends_on = [
    module.vpcs
  ]
}

module "instancies" {
  source         = "./modules/instancies"
  for_each       = local.instancies
  subnet_id      = element(compact(one(module.vpcs.*.vpcs.subnet_id)), 0)
  type_instances = lookup(each.value, "type_instances")
  depends_on = [
    module.vpcs
  ]
}
module "dns_zone" {
  source           = "./modules/dns_zone"
  for_each         = local.zones
  domain_name      = each.key
  records          = lookup(each.value, "records")
  public           = lookup(each.value, "public")
  zone_name        = lookup(each.value, "name")
  private_networks = lookup(each.value, "private_networks", null)
}
module "inventory" {
  source      = "./modules/inventory"
  ip_instance = one(module.instancies[*].instancies.external_ip_address)
  depends_on = [
    module.vpcs,
    module.instancies
  ]
}

module "k8s_security_group" {
  source     = "./modules/security_group"
  network_id = one(module.vpcs.*.vpcs.network_id)
  depends_on = [
    module.vpcs
  ]
}
module "yandex_kubernetes_cluster" {
  source                  = "./modules/yandex_kubernetes_cluster"
  network_id              = one(module.vpcs.*.vpcs.network_id)
  name_cluster            = "kube-infra"
  subnet_id               = element(compact(one(module.vpcs.*.vpcs.subnet_id)), 0)
  zone                    = local.zone
  security_group_ids      = module.k8s_security_group.security_group_name
  service_account_id      = module.service_account.service_account_id
  node_service_account_id = module.service_account.service_account_id
  depends_on = [
    module.service_account,
    module.vpcs
  ]
}
module "kubernetes_node_group" {
  source     = "./modules/kubernetes_node_group"
  name_node  = "kube-infra"
  cluster_id = module.yandex_kubernetes_cluster.cluster_id
  subnet_ids = element(compact(one(module.vpcs.*.vpcs.subnet_id)), 0)
  depends_on = [
    module.k8s_security_group,
    module.service_account,
    module.yandex_kubernetes_cluster,
    module.vpcs
  ]
}