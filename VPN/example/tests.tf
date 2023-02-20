# ====================
# Tests for deployment
# ====================

resource "null_resource" "test_ipsec_status" {

  connection {
    type = "ssh"
    user = "admin"
    private_key = "${file(var.ssh_private_key)}"
    host = "${module.vpn.cil_sgw_public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo ipsec status",
    ]
  }

  depends_on = [
    module.vpn.yandex_compute_instance,
    yandex_compute_instance.vm_instance,
    module.vpn.aws_vpn_connection,
    aws_instance.vm_instance
  ]
}

resource "null_resource" "test_vm_ping" {

  connection {
    type = "ssh"
    user = "admin"
    private_key = "${file(var.ssh_private_key)}"
    bastion_host = "${module.vpn.cil_sgw_public_ip}"
    host = "${yandex_compute_instance.vm_instance.network_interface.0.ip_address}"
  }

  provisioner "remote-exec" {
    inline = [
      "ping -c10 ${aws_instance.vm_instance.private_ip}",
    ]
  }

  depends_on = [ 
    null_resource.test_ipsec_status
  ]
}
