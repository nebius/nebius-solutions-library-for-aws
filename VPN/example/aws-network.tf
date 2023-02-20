
resource "aws_vpc" "vpc" {
  cidr_block = var.aws_subnet_prefix

  tags = {
    Name = "vpn-vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = var.aws_subnet_prefix

  tags = {
    Name = "vpn-subnet"
  }
}

resource "aws_internet_gateway" "inet_gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "vpn-inet-gw"
  }
}

resource "aws_route_table" "subnet_rt" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.inet_gw.id}"
  }

  tags = {
    Name = "vpn-subnet-rt"
  }
}

resource "aws_main_route_table_association" "subnet_rt" {
  vpc_id = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.subnet_rt.id}"
}

resource "aws_security_group" "vm_sg" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpn-vm-sg"
  }
}