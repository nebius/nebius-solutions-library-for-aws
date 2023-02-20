
resource "yandex_vpc_network" "network" {
  name = "vpn-network"
}

resource "yandex_vpc_security_group" "vm_sg" {
  name = "vm-instance-sg"
  network_id = "${yandex_vpc_network.network.id}"

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
