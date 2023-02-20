
module "mk8s" {
  source = "./mk8s"

  folder_id = var.folder_id
  zone_id = var.zone_id
  mk8s_sa_name = var.mk8s_sa_name
  cluster_name = var.mk8s_name
  cluster_net_id = "${yandex_vpc_network.mk8s_net.id}"
  cluster_subnet_id = "${yandex_vpc_subnet.subnet1.id}"
  cluster_subnet_prefix = var.subnet1_priv_prefix
  k8s_version = var.k8s_version
  k8s_svc_ipv4_subnet = var.k8s_svc_ipv4_subnet
  mk8s_pod_ipv4_subnet = var.mk8s_pod_ipv4_subnet
  ssh_pub_key = var.ssh_pub_key
  k8s_whitelist = var.k8s_whitelist
}
