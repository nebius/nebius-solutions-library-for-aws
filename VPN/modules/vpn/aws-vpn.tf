
resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = var.aws_vpc_id

  tags = {
    Name = "vpn-gateway"
  }
}

resource "aws_customer_gateway" "vpn_customer_gw" {
  bgp_asn = 65000
  ip_address = "${yandex_vpc_address.sgw_pub_ip.external_ipv4_address.0.address}"
  type = "ipsec.1"

  tags = {
    Name = "vpn-customer-gateway"
  }
}

resource "aws_vpn_connection" "vpn_conn" {
  vpn_gateway_id = "${aws_vpn_gateway.vpn_gw.id}"
  customer_gateway_id = "${aws_customer_gateway.vpn_customer_gw.id}"
  type = "ipsec.1"
  tunnel1_ike_versions = ["ikev2"]
  tunnel1_preshared_key = var.vpn_secret
  static_routes_only = true

  tags = {
    Name = "vpn-connection"
  }
}

resource "aws_vpn_connection_route" "vpn_conn_route" {
  destination_cidr_block = var.cil_subnet_prefix
  vpn_connection_id = "${aws_vpn_connection.vpn_conn.id}"
}

resource "aws_vpn_gateway_route_propagation" "vpn_gw_route_prop" {
  vpn_gateway_id = "${aws_vpn_gateway.vpn_gw.id}"
  route_table_id = var.aws_rt_id
}
