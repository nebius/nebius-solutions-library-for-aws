
module "vpn" {
  source = "../modules/vpn"

  ssh_public_key = var.ssh_public_key
  vpn_secret = var.vpn_psk

  # CloudIL variables
  cloud_id = var.cloud_id
  folder_id = var.folder_id
  zone_id = var.zone_id
  token = var.token

  cil_vpc_id = "${yandex_vpc_network.network.id}"
  cil_subnet_prefix = var.cil_subnet_prefix

  # AWS variables
  aws_region = var.aws_region
  aws_profile = var.aws_profile

  aws_vpc_id = "${aws_vpc.vpc.id}"
  aws_subnet_prefix = var.aws_subnet_prefix
  aws_rt_id = "${aws_route_table.subnet_rt.id}"
}
