
# =================
# AWS VPC Resources
# =================

data "aws_availability_zones" "az_list" {
  state = "available"
}

# Create VPC (Network)
resource "aws_vpc" "vpc" {
  cidr_block = var.net_ipv4_prefix
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.net_name}"
  }
}

# Create Security Group for Subnets
resource "aws_default_security_group" "vpc_default_sg" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    protocol = -1
    self = true
    from_port = 0
    to_port = 0
  }

  ingress {
    protocol = "icmp"
    from_port = -1
    to_port = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Internet Gateway (IGW) at VPC level
resource "aws_internet_gateway" "inet_gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "vpc-inet-gw"
  }
}

# Enable Internet routing via IGW
resource "aws_default_route_table" "vpc_default_rt" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.inet_gw.id}"
  }
}


# =================
# Subnet1 Resources
# =================

# Create Subnet1 Private
resource "aws_subnet" "subnet1_priv" {
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = data.aws_availability_zones.az_list.names[0]
  cidr_block = var.subnet1_priv_prefix

  tags = {
    "Name" = "${var.subnet1_priv_name}"
    #"kubernetes.io/role/elb" = "1"
    #"kubernetes.io/role/internal-elb" = "1"
  }
}

# Create Subnet1 Public (for the NAT Gateway)
resource "aws_subnet" "subnet1_pub" {
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = data.aws_availability_zones.az_list.names[0]
  cidr_block = var.subnet1_pub_prefix
  # map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.subnet1_pub_name}"
  }
}


# Public IP address for NAT Gateway
resource "aws_eip" "subnet1_pub_eip" {
  vpc = true
}

# NAT Gateway in Subnet1 Public
resource "aws_nat_gateway" "subnet1_nat_gw" {
  connectivity_type = "public"
  allocation_id = "${aws_eip.subnet1_pub_eip.id}"
  subnet_id = "${aws_subnet.subnet1_pub.id}"

  depends_on = [aws_eip.subnet1_pub_eip]

  tags = {
    Name = "${var.subnet1_pub_name}-nat-gw"
  }
}


# Create Route Table for Subnet1 Private
resource "aws_route_table" "subnet1_priv_rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.subnet1_nat_gw.id}"
  }
  tags = {
    Name = "${var.subnet1_priv_name}-rt"
  }
}

# Apply Route Table to Subnet1 Private
resource "aws_route_table_association" "subnet1_priv_rt" {
  route_table_id = "${aws_route_table.subnet1_priv_rt.id}"
  subnet_id = "${aws_subnet.subnet1_priv.id}"
}


# =================
# Subnet2 Resources
# =================

# Create Subnet2 Private
resource "aws_subnet" "subnet2_priv" {
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = data.aws_availability_zones.az_list.names[1]
  cidr_block = var.subnet2_priv_prefix

  tags = {
    "Name" = "${var.subnet2_priv_name}"
    #"kubernetes.io/role/elb" = "1"
    #"kubernetes.io/role/internal-elb" = "1"
  }
}

# Create Subnet2 Public (for the NAT Gateway)
resource "aws_subnet" "subnet2_pub" {
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = data.aws_availability_zones.az_list.names[1]
  cidr_block = var.subnet2_pub_prefix
  # map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.subnet2_pub_name}"
  }
}


# Public IP address for NAT Gateway
resource "aws_eip" "subnet2_pub_eip" {
  vpc = true
}

# NAT Gateway in Subnet2 Public
resource "aws_nat_gateway" "subnet2_nat_gw" {
  connectivity_type = "public"
  allocation_id = "${aws_eip.subnet2_pub_eip.id}"
  subnet_id = "${aws_subnet.subnet2_pub.id}"

  depends_on = [aws_eip.subnet2_pub_eip]

  tags = {
    Name = "${var.subnet2_pub_name}-nat-gw"
  }
}


# Create Route Table for Subnet2 Private
resource "aws_route_table" "subnet2_priv_rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.subnet2_nat_gw.id}"
  }
  tags = {
    Name = "${var.subnet2_priv_name}-rt"
  }
}

# Apply Route Table to Subnet2 Private
resource "aws_route_table_association" "subnet2_priv_rt" {
  route_table_id = "${aws_route_table.subnet2_priv_rt.id}"
  subnet_id = "${aws_subnet.subnet2_priv.id}"
}
