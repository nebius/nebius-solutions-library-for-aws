# ============================
# CloudIL Environment Settings
# ============================

variable "cloud_id" {
}

variable "folder_id" {
}

variable "token" {
}

variable "zone_id" {
}

# ========================
# AWS Environment Settings
# ========================

variable "aws_region" {
} 

variable "aws_profile" {
} 

# ===============
# Input Variables
# ===============

variable "ssh_public_key" {
  description = "Path to SSH public key file"
}

variable "vpn_secret" {
  description = "IPSEC pre-shared key (psk)"
}

variable "cil_vpc_id" {
  description = "ID of the CloudIL VPC where VPN instance will be created"
}

variable "cil_subnet_prefix" {
  description = "CloudIL IPv4 subnet prefix where VPN instance will be created"
}

variable "aws_vpc_id" {
  description = "ID of the AWS VPC where VPN gateway will be attached"
}

variable "aws_subnet_prefix" {
  description = "AWS IPv4 subnet prefix where VPN instance will be created"
}

variable "aws_rt_id" {
  description = "ID of the AWS RT where VPN routes will be propagated"
}

# =======
# Outputs
# =======

output "cil_subnet_id" {
  value = "${yandex_vpc_subnet.cil_subnet.id}"
}

output "cil_sgw_public_ip" {
  value = "${aws_customer_gateway.vpn_customer_gw.ip_address}"
}

output "aws_sgw_public_ip" {
  value = "${aws_vpn_connection.vpn_conn.tunnel1_address}"
}
