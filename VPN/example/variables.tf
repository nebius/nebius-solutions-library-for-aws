# ============================
# CloudIL Environment Settings
# ============================

variable "cloud_id" {
  description = "Taken from the environment variable"
}

variable "folder_id" {
  description = "Taken from the environment variable"
}

variable "token" {
  description = "Taken from the environment variable"
}

variable "zone_id" {
  default = "il1-a"
}

# ========================
# AWS Environment Settings
# ========================

variable "aws_region" {
  default = "eu-central-1"
} 

variable "aws_profile" {
  default = "aws"
} 

# ===============
# Input Variables
# ===============

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa"
}


variable "cil_image_family" {
  default = "ubuntu-2004-lts"
}

variable "cil_subnet_prefix" {
  default = "10.10.0.0/24"
}

variable "aws_subnet_prefix" {
  default = "10.250.0.0/24"
}

variable "vpn_psk" {
  description = "IPSEC pre-shared key (secret) for both sides"
  default = "vfFdKPv2pu35s3fU2tu"
}

# =======
# Outputs
# =======

output "cil_sgw_public_ip" {
  value = "${module.vpn.cil_sgw_public_ip}"
}

output "aws_sgw_public_ip" {
  value = "${module.vpn.aws_sgw_public_ip}"
}
