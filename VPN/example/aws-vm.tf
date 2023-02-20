
data "aws_ami" "vm_image" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "template_file" "aws_vm_cloud_init" {
  template = file("aws-vm.tpl")
  vars = {
    ssh_key = file(var.ssh_public_key)
  }
}

resource "aws_instance" "vm_instance" {
  ami = "${data.aws_ami.vm_image.id}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet.id}"
  private_ip = cidrhost(var.aws_subnet_prefix, 10)
  vpc_security_group_ids = [aws_security_group.vm_sg.id]
  # associate_public_ip_address = true
  user_data = "${data.template_file.aws_vm_cloud_init.rendered}"

  tags = {
    Name = "vpn-vm-instance"
  }
}

# =======
# Outputs
# =======

output "aws_vm_internal_ip" {
  value = "${aws_instance.vm_instance.private_ip}"
}
