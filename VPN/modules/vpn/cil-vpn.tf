
resource "yandex_compute_image" "sgw_image" {
  source_family = "ipsec-instance-ubuntu"
}

data "template_file" "vpn_cloud_init" {
  template = file("${path.module}/vpn-config.tpl")
  vars = {
    ssh_key = file(var.ssh_public_key)
    left_id = "${yandex_vpc_address.sgw_pub_ip.external_ipv4_address.0.address}"
    right = "${aws_vpn_connection.vpn_conn.tunnel1_address}"
    leftsubnet = "${var.cil_subnet_prefix}"
    rightsubnet = "${var.aws_subnet_prefix}"
    psk = "${var.vpn_secret}"
  }
}

resource "yandex_compute_instance" "sgw_vm" {
  name = "vpn-vm"
  hostname = "vpn-vm"
  description = "vpn-vm"
  zone = var.zone_id
  platform_id = "standard-v3"

  resources {
    cores = 2
    memory = 4
    core_fraction = "100"
  }
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image_id = "${yandex_compute_image.sgw_image.id}"
      type = "network-ssd"
      size = "20"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.cil_subnet.id}"
    ip_address = cidrhost(var.cil_subnet_prefix, 5)
    nat = true
    nat_ip_address = "${yandex_vpc_address.sgw_pub_ip.external_ipv4_address.0.address}"
    security_group_ids = [yandex_vpc_security_group.sgw_vm_sg.id]
  }

  metadata = {
    user-data = "${data.template_file.vpn_cloud_init.rendered}"
  }
}
