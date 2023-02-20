
resource "yandex_vpc_address" "sgw_pub_ip" {
  name = "vpn-address"
  external_ipv4_address {
    zone_id = var.zone_id
  }
}

resource "yandex_vpc_subnet" "cil_subnet" {
  name = "${var.cil_vpc_id}-subnet"
  zone = var.zone_id
  network_id = var.cil_vpc_id
  v4_cidr_blocks = [var.cil_subnet_prefix]
  route_table_id = "${yandex_vpc_route_table.cil_subnet_rt.id}"
}

resource "yandex_vpc_route_table" "cil_subnet_rt" {
  name = "subnet-rt"
  network_id = var.cil_vpc_id

  static_route {
    destination_prefix = var.aws_subnet_prefix
    next_hop_address = cidrhost(var.cil_subnet_prefix, 5)
  }
}

resource "yandex_vpc_security_group" "sgw_vm_sg" {
  name = "sgw-vm-sg"
  network_id = var.cil_vpc_id

  ingress {
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port = 500
  }

  ingress {
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port = 4500
  }

  ingress {
    protocol = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port = 22

  }
  ingress {
    protocol = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 65535
  }

  egress {
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 65535
  }
}
