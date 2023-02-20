
# ====================
# Create VPC (Network)
# ====================

resource "yandex_vpc_network" "mk8s_net" {
  name = var.net_name
  folder_id = var.folder_id
}

# ==============
# Create Subnet1
# ==============

resource "yandex_vpc_subnet" "subnet1" {
  name = var.subnet1_priv_name
  zone = var.zone_id
  network_id = "${yandex_vpc_network.mk8s_net.id}"
  v4_cidr_blocks = [var.subnet1_priv_prefix]
}
